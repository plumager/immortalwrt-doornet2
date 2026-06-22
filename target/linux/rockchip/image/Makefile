# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

DEVICE_VARS += UBOOT_DEVICE_NAME

define Build/Compile
	$(CP) $(LINUX_DIR)/COPYING $(KDIR)/COPYING.linux
endef

define Build/boot-common
	rm -fR $@.boot
	mkdir -p $@.boot
	$(CP) $(IMAGE_KERNEL) $@.boot/kernel.img
endef

define Build/boot-script
	mkimage -A arm -O linux -T script -C none -a 0 -e 0 \
		-d $(if $(1),$(1),default).bootscript $@.boot/boot.scr
endef

define Build/pine64-img
	PADDING=1 $(SCRIPT_DIR)/gen_image_generic.sh \
		$@ $(CONFIG_TARGET_KERNEL_PARTSIZE) $@.boot \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(IMAGE_ROOTFS) 32768
	dd if="$(STAGING_DIR_IMAGE)/$(UBOOT_DEVICE_NAME)-u-boot-rockchip.bin" \
		of="$@" seek=64 conv=notrunc
endef

define Build/pine64-bin
	PADDING=1 $(SCRIPT_DIR)/gen_image_generic.sh \
		$@ $(CONFIG_TARGET_KERNEL_PARTSIZE) $@.boot \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(IMAGE_ROOTFS) 32768
	dd if="$(STAGING_DIR_IMAGE)/rk3399-idbloader.bin" of="$@" seek=64 conv=notrunc
	dd if="$(STAGING_DIR_IMAGE)/$(UBOOT_DEVICE_NAME)-uboot.img" of="$@" seek=16384 conv=notrunc
	dd if="$(STAGING_DIR_IMAGE)/rk3399-trust.bin" of="$@" seek=24576 conv=notrunc
endef

define Device/Default
  PROFILES := Default
  KERNEL := kernel-bin | lzma | fit lzma $$(KDIR)/image-$$(DEVICE_DTS).dtb
  KERNEL_LOADADDR := 0x00080000
  BOOT_SCRIPT := rockchip
  IMAGES := sysupgrade.img.gz
  IMAGE/sysupgrade.img.gz := boot-common | boot-script $$(BOOT_SCRIPT) | pine64-img | gzip | append-metadata
  DEVICE_DTS_DIR := ../dts
  SOC := rk3399
endef

define Device/embedfire_doornet2
  DEVICE_VENDOR := EmbedFire
  DEVICE_MODEL := DoorNet2
  DEVICE_DTS := rk3399-embedfire-doornet2
  UBOOT_DEVICE_NAME := doornet2-rk3399
  SOC := rk3399
  DEVICE_PACKAGES := kmod-r8169 -urngd
  IMAGE/sysupgrade.img.gz := boot-common | boot-script $$(BOOT_SCRIPT) | pine64-bin | gzip | append-metadata
endef
TARGET_DEVICES += embedfire_doornet2

include $(SUBTARGET).mk
$(eval $(call BuildImage))
