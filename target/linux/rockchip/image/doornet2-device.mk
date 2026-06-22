define Device/embedfire_doornet2
  DEVICE_VENDOR := EmbedFire
  DEVICE_MODEL := DoorNet2
  DEVICE_DTS := rk3399-embedfire-doornet2
  KERNEL_LOADADDR := 0x00080000
  UBOOT_DEVICE_NAME := nanopi-r4s-rk3399
  SOC := rk3399
  DEVICE_PACKAGES := kmod-r8169 -urngd
  IMAGES := rootfs.tar.gz
  IMAGE/rootfs.tar.gz := rootfs | tar.gz
  IMAGES += kernel.bin
  IMAGE/kernel.bin := kernel-bin | lzma | fit lzma $$(KDIR)/image-$$(DEVICE_DTS).dtb
endef
TARGET_DEVICES += embedfire_doornet2
