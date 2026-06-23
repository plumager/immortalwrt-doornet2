# Custom image recipe - same as pine64-img but U-Boot dd is optional (non-fatal)
define Build/doornet2-img
	PADDING=1 $(SCRIPT_DIR)/gen_image_generic.sh \
		$@ $(CONFIG_TARGET_KERNEL_PARTSIZE) $@.boot \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(IMAGE_ROOTFS) 32768
	-dd if="$(STAGING_DIR_IMAGE)/$(UBOOT_DEVICE_NAME)-u-boot-rockchip.bin" \
		of="$@" seek=64 conv=notrunc 2>/dev/null || true
endef

define Device/embedfire_doornet2
  DEVICE_VENDOR := EmbedFire
  DEVICE_MODEL := DoorNet2
  DEVICE_DTS := rk3399-embedfire-doornet2
  KERNEL_LOADADDR := 0x00080000
  UBOOT_DEVICE_NAME := nanopi-r4s-rk3399
  SOC := rk3399
  DEVICE_PACKAGES := kmod-r8169 -urngd
  IMAGES := sysupgrade.img.gz
  IMAGE/sysupgrade.img.gz := boot-common | boot-script | doornet2-img | gzip | append-metadata
endef
TARGET_DEVICES += embedfire_doornet2
