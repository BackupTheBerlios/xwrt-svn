# Main makefile for the packages
include $(TOPDIR)/rules.mk

package-$(BR2_PACKAGE_KMOD_DIAG) += diag
package-$(BR2_PACKAGE_KMOD_FUSE) += fuse
package-$(BR2_PACKAGE_KMOD_SHFS) += shfs
package-$(BR2_PACKAGE_KMOD_SWITCH) += switch
package-$(BR2_PACKAGE_KMOD_NOZOMI) += nozomi
package-$(BR2_PACKAGE_KMOD_OPENSWAN) += openswan
package-$(BR2_PACKAGE_KMOD_MADWIFI) += madwifi
package-$(BR2_PACKAGE_KMOD_USB_SPCA5XX) += spca5xx
package-$(BR2_PACKAGE_KMOD_USB_SPCA5XX_LE) += spca5xx-le
package-$(BR2_PACKAGE_KMOD_USB_MOS7715) += mos7715
package-y += openwrt

package-$(BR2_PACKAGE_KMOD_WLCOMPAT) += wlcompat
wlcompat-compile: openwrt-compile

all: compile install
clean: $(patsubst %,%-clean,$(package-) $(package-y) $(package-m))
compile: $(patsubst %,%-compile,$(package-y) $(package-m))
install: $(patsubst %,%-install,$(package-y))

MAKEOPTS:=	BOARD="$(BOARD)" \
		IPKG="$(IPKG)" \
		TARGET_DIR="$(TARGET_DIR)" \
		BUILD_DIR="$(BUILD_DIR)" \
		KERNEL_DIR="$(KERNEL_DIR)" \
		LINUX_VERSION="$(LINUX_VERSION)" \
		KERNEL_RELEASE="$(KERNEL_RELEASE)"


%-prepare:
	$(MAKE) -C $(patsubst %-prepare,%,$@) \
		$(MAKEOPTS) \
		prepare

%-compile: %-prepare 
	$(MAKE) -C $(patsubst %-compile,%,$@) \
		$(MAKEOPTS) \
		compile

%-install: %-compile
	$(MAKE) -C $(patsubst %-install,%,$@) \
		$(MAKEOPTS) \
		install

%-clean:
	@$(MAKE) -C $(patsubst %-clean,%,$@) clean

