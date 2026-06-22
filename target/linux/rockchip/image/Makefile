# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

DEVICE_VARS += UBOOT_DEVICE_NAME

define Build/Compile
	$(CP) $(LINUX_DIR)/COPYING $(KDIR)/COPYING.linux
endef

### Image scripts ###
define Build/boot-common
	# This creates a new folder copies the dtb (as rockchip.dtb) 
	# and the kernel image (as kernel.img)
	rm -fR $@.boot
	mkdir -p $@.boot

	$(CP) $(IMAGE_KERNEL) $@.boot/kernel.img
endef

define Build/boot-script
	# Make an U-boot image and copy it to the boot partition
	mkimage -A arm -O linux -T script -C none -a 0 -e 0 -d $(if $(1),$(1),default).bootscript $@.boot/boot.scr
endef

define Build/pine64-img
	# Creates the final SD/eMMC images, 
	# combining boot partition, root partition as well as the u-boot bootloader
	# Generate a new partition table in $@ with 32 MiB of 
	# alignment padding for the u-boot-rockchip.bin (idbloader + u-boot) to fit:
	# http://opensource.rock-chips.com/wiki_Boot_option#Boot_flow
	#
	# U-Boot SPL expects the U-Boot ITB to be located at sector 0x4000 (8 MiB) on the MMC storage
	PADDING=1 $(SCRIPT_DIR)/gen_image_generic.sh \
		$@ \
		$(CONFIG_TARGET_KERNEL_PARTSIZE) $@.boot \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(IMAGE_ROOTFS) \
		32768

	# Copy the u-boot-rockchip.bin to the image at sector 0x40
	dd if="$(STAGING_DIR_IMAGE)/$(UBOOT_DEVICE_NAME)-u-boot-rockchip.bin" of="$@" seek=64 conv=notrunc
endef

define Build/pine64-bin
	# Typical Rockchip boot flow with Rockchip miniloader
	# Generate a new partition table in $@ with 32 MiB of alignment
	# padding for the idbloader, uboot and trust image to fit
	PADDING=1 $(SCRIPT_DIR)/gen_image_generic.sh \
		$@ \
		$(CONFIG_TARGET_KERNEL_PARTSIZE) $@.boot \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(IMAGE_ROOTFS) \
		32768

	# Copy the idbloader, uboot and trust image to the image
	dd if="$(STAGING_DIR_IMAGE)/$(SOC)-idbloader.bin" of="$@" seek=64 conv=notrunc
	dd if="$(STAGING_DIR_IMAGE)/$(UBOOT_DEVICE_NAME)-uboot.img" of="$@" seek=16384 conv=notrunc
	dd if="$(STAGING_DIR_IMAGE)/$(SOC)-trust.bin" of="$@" seek=24576 conv=notrunc
endef

### Devices ###
define Device/Default
  PROFILES := Default
  KERNEL = kernel-bin | lzma | fit lzma $$(DTS_DIR)/$$(DEVICE_DTS).dtb
  KERNEL_LOADADDR := 0x00080000
  BOOT_SCRIPT := rockchip
  IMAGES := sysupgrade.img.gz
  IMAGE/sysupgrade.img.gz = boot-common | boot-script $$(BOOT_SCRIPT) | pine64-img | gzip | append-metadata
  DEVICE_DTS_DIR := ../dts
  DEVICE_DTS = $$(SOC)-$(lastword $(subst _, ,$(1)))
  UBOOT_DEVICE_NAME = $(lastword $(subst _, ,$(1)))-$$(SOC)
endef

# DoorNet2 - EmbedFire DoorNet2 (RK3399)
define Device/embedfire_doornet2
  DEVICE_VENDOR := EmbedFire
  DEVICE_MODEL := DoorNet2
  SOC := rk3399
  UBOOT_DEVICE_NAME := doornet2-rk3399
  DEVICE_DTS := rk3399-embedfire-doornet2
  DEVICE_PACKAGES := kmod-rtl8169 -urngd
  IMAGE/sysupgrade.img.gz := boot-common | boot-script $$(BOOT_SCRIPT) | pine64-bin | gzip | append-metadata
endef
TARGET_DEVICES += embedfire_doornet2

include $(SUBTARGET).mk

$(eval $(call BuildImage))
