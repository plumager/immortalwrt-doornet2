================================================================================
          ImmortalWrt Firmware for EmbedFire DoorNet2 (RK3399)
================================================================================

目录
====
1. 概述
2. 硬件规格
3. 文件结构
4. 编译方法
5. 刷机方法
6. 固件默认配置
7. 常见问题

================================================================================
1. 概述
================================================================================

本仓库为野火(EmbedFire) DoorNet2 软路由适配 ImmortalWrt 固件的源码补丁集。

DoorNet2 是野火电子推出的鲁班猫系列产品，基于 Rockchip RK3399 处理器，
定位为高性能工业和家用智能网关。

对比原厂固件，本适配的特色：
  - 基于最新 ImmortalWrt master 分支（内核 6.18）
  - 完整的设备树支持（eMMC、双千兆、USB3.0、LED、按键、风扇）
  - 网络性能优化（IRQ 绑定到 A72 大核、RPS 队列）
  - 预置常用插件包（参见 diffconfig）
  - 支持超频到 2.0GHz（可选）

================================================================================
2. 硬件规格
================================================================================

  SoC:       Rockchip RK3399
             双核 Cortex-A72 @ 1.8GHz (可超频至 2.0GHz)
             四核 Cortex-A53 @ 1.4GHz
             GPU: Mali-T864

  RAM:       Dual-Channel DDR3 1GB (2x 512MB)

  存储:      板载 eMMC 8GB
             microSD 卡槽（TF卡）

  网络:
            eth0 - 原生 GMAC (RGMII) 千兆以太网
            eth1 - PCIe 转 RTL8168 千兆以太网

  WiFi:      USB2.0 WiFi 模块 (选配)
             支持 802.11 a/b/g/n/ac，最高 433Mbps

  USB:       2x USB 3.0 Type-A

  电源:      USB Type-C 5V/3A

  LED:       P - 电源灯
             S - 系统状态灯
             W/L - WAN/LAN 网络状态灯

  按键:      F - Flash 烧录/恢复模式
             R - Reset 重启/恢复出厂

  风扇:      PWM 调速风扇接口 (仅风扇版本)

  串口:      UART2 调试串口 (3.3V TTL, 1500000 baud)

================================================================================
3. 文件结构
================================================================================

target/linux/rockchip/
├── dts/
│   └── rk3399-embedfire-doornet2.dts          # 设备树源文件
├── image/
│   └── Makefile                                # 镜像构建脚本 + 设备定义
├── armv8/
│   ├── target.mk                               # 子目标配置
│   └── base-files/
│       ├── etc/board.d/02_network              # 网络接口配置
│       └── lib/preinit/
│           ├── 02_sysinfo                      # 设备型号识别
│           └── 05_preinit_network              # 预启动网络配置
├── patches-6.18/
│   └── 001-add-doornet2-dtb.patch              # Linux 内核 DTB 注册补丁
└── files-6.18/
    └── arch/arm64/boot/dts/rockchip/           # (备用DTS目录)

package/boot/uboot-rockchip/patches/
└── 300-rockchip-add-embedfire-doornet2.patch   # U-Boot 板级支持补丁

================================================================================
4. 编译方法
================================================================================

4.1 环境要求
----------------
  - Ubuntu 22.04 LTS (推荐) 或 Debian 12
  - CPU: x86_64, 至少 4 核
  - RAM: 至少 8GB (推荐 16GB)
  - 磁盘: 至少 50GB 可用空间
  - 稳定的网络连接（需要下载大量源码包）

4.2 安装依赖
----------------

  sudo apt update
  sudo apt install -y build-essential clang flex bison g++ gawk \
  gcc-multilib g++-multilib gettext git libncurses-dev libssl-dev \
  python3 python3-distutils python3-setuptools rsync unzip zlib1g-dev \
  file wget curl qemu-utils

4.3 编译步骤
----------------

  # 1. 克隆 ImmortalWrt 源码
  git clone https://github.com/immortalwrt/immortalwrt.git
  cd immortalwrt

  # 2. 切换分支（建议使用 master 分支）
  git checkout master

  # 3. 将本仓库的适配文件复制到源码目录
  # 方法 A: 手动复制文件（推荐，可选择性合并）
  cp -r /path/to/immortalwrt-doornet2/target/linux/rockchip/* target/linux/rockchip/
  cp /path/to/immortalwrt-doornet2/package/boot/uboot-rockchip/patches/* \
     package/boot/uboot-rockchip/patches/

  # 方法 B: 直接打补丁
  # 暂不支持，后续提供

  # 4. 更新 feeds
  ./scripts/feeds update -a
  ./scripts/feeds install -a

  # 5. 配置固件
  # 导入 DoorNet2 默认配置，或者手动选择：
  #   Target System:   Rockchip
  #   Subtarget:       RK33xx/RK35xx boards (64 bit)
  #   Target Profile:  EmbedFire DoorNet2
  cp /path/to/immortalwrt-doornet2/docs/diffconfig .config
  make defconfig

  # 或者手动配置：
  # make menuconfig

  # 6. 开始编译
  # -j$(nproc) 表示使用所有 CPU 核心，可根据实际情况调整
  make -j$(nproc) 2>&1 | tee build.log

  # 7. 编译完成后，固件位于
  ls -la bin/targets/rockchip/armv8/
  # 主要文件：
  #   immortalwrt-*-rockchip-armv8-embedfire_doornet2-sysupgrade.img.gz
  #   immortalwrt-*-rockchip-armv8-embedfire_doornet2-ext4-sysupgrade.img.gz

4.4 Docker 编译（适用于 Windows）
----------------

  # 拉取 ImmortalWrt 预编译容器
  docker pull immortalwrt/imagebuilder:rockchip-armv8-openwrt-24.10

  # 使用 imagebuilder 快速构建（不需要完整的编译环境）
  # 详情见 ImmortalWrt 官方文档

================================================================================
5. 刷机方法
================================================================================

5.1 线刷到 eMMC（首次刷机）
-----------------------------
  注意：DoorNet2 使用 Rockchip 的 Maskrom 模式刷机。

  所需工具：
    - USB 双公头数据线
    - PC 端刷机工具：RKDevTool (Windows) 或 rkdeveloptool (Linux/Mac)
    - DoorNet2 固件：sysupgrade.img.gz

  步骤：
    1. 解压固件：gzip -d immortalwrt-*-embedfire_doornet2-sysupgrade.img.gz
    2. 按住 F(Flash) 键不放
    3. 插入 USB Type-C 电源，等待 2 秒
    4. 用 USB 双公头线连接 PC 和 DoorNet2 的 USB3.0 口
    5. PC 端检测到 Maskrom 设备
    6. 使用 RKDevTool/rkdeveloptool 烧录固件到 eMMC
    7. 烧录完成后，断开 USB，重新上电启动

  Windows (RKDevTool):
    - 打开 RKDevTool
    - 点击"升级固件" -> "固件" -> 选择解压后的 .img 文件
    - 点击"升级"开始烧录

  Linux:
    sudo rkdeveloptool db rk3399_loader.bin
    sudo rkdeveloptool wl 0x0 firmware.img
    sudo rkdeveloptool rd

5.2 TF 卡启动（测试用）
-------------------------
  将固件写入 TF 卡：
    gunzip -c immortalwrt-*-embedfire_doornet2-sysupgrade.img.gz | \
      sudo dd of=/dev/sdX bs=1M status=progress
    sync

  插入 TF 卡，按住 F 键上电启动（优先从 TF 卡启动）

5.3 Web 更新 (sysupgrade)
--------------------------
  在现有 ImmortalWrt/OpenWrt 系统中，通过 LuCI Web 界面：
    系统 -> 备份/升级 -> 刷写新的固件
    选择 sysupgrade.img.gz 文件

  或者 SSH 命令行：
    sysupgrade -n /path/to/immortalwrt-*-embedfire_doornet2-sysupgrade.img.gz

================================================================================
6. 固件默认配置
================================================================================

  管理地址:  http://192.168.1.1
  用户名:    root
  密码:      password

  网络接口:
    eth0 - WAN (默认 DHCP 客户端)
    eth1 - LAN (192.168.1.1/24)

  预装软件包:
    - luci (Web 管理界面)
    - luci-app-firewall
    - luci-app-statistics (系统监控)
    - luci-app-turboacc (网络加速)
    - luci-app-upnp
    - openssh-sftp-server
    - tcpdump
    - iperf3
    - htop
    - nano

  性能优化:
    - IRQ 绑定: GMAC 中断绑定到 CPU4 (A72), PCIe 中断绑定到 CPU5 (A72)
    - RPS/XPS: 启用网卡多队列 RSS
    - TCP BBR: 默认启用 BBR 拥塞控制算法
    - Flow Offloading: 默认启用软件 NAT 加速

  可选超频:
    修改 DTS 中 opp 表或使用 cpufreq 工具：
      echo 2000000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
      echo 2000000 > /sys/devices/system/cpu/cpu5/cpufreq/scaling_max_freq

================================================================================
7. 常见问题
================================================================================

Q: 编译失败提示 "No rule to make target ..."？
A: 运行 make defconfig 后，确保 Target Profile 选择了 DoorNet2。
   或者先运行 make clean 再重新编译。

Q: 如何优化 DoorNet2 的网络性能？
A: 默认配置已经做了 IRQ 亲和性绑定。如需进一步优化：
   1. 确认网卡驱动: ethtool -i eth0
   2. 查看 IRQ 分配: cat /proc/interrupts | grep eth
   3. 手动调整: echo 10 > /proc/irq/XX/smp_affinity (CPU4)

Q: eMMC 启动失败，LED 不亮？
A: 可能是 U-Boot 没有正确烧录。尝试：
   1. 使用 TF 卡启动
   2. 重新用 RKDevTool 线刷

Q: 如何恢复出厂设置？
A: 通电后长按 Reset 键 5 秒以上（仅 squashfs 格式镜像适用）

Q: 可以使用 DoorNet1 的固件吗？
A: 不可以。DoorNet1 和 DoorNet2 硬件完全不同（DoorNet1 使用全志 H5），
   本适配仅适用于 DoorNet2 (RK3399)。

Q: WiFi 模块不工作？
A: DoorNet2 的 WiFi 模块为选配件（USB 接口）。如未安装 WiFi 模块，
   请在系统 -> 软件包中卸载 hostapd 和 wpa_supplicant 以节省资源。

================================================================================
