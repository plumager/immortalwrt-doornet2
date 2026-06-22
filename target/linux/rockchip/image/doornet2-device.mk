define Device/embedfire_doornet2
  DEVICE_VENDOR := EmbedFire
  DEVICE_MODEL := DoorNet2
  DEVICE_DTS := rk3399-embedfire-doornet2
  KERNEL_LOADADDR := 0x00080000
  UBOOT_DEVICE_NAME := doornet2-rk3399
  SOC := rk3399
  DEVICE_PACKAGES := kmod-r8169 -urngd
  IMAGE/sysupgrade.img.gz := boot-common | boot-script $$(BOOT_SCRIPT) | pine64-img | gzip | append-metadata
endef
TARGET_DEVICES += embedfire_doornet2
