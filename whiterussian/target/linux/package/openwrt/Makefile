# $Id: Makefile 2252 2005-10-22 19:42:46Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME := base-files-arch
PKG_RELEASE := 2
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(TOPDIR)/package/rules.mk

IDIR_OPENWRT:=$(PKG_BUILD_DIR)/ipkg
IPKG_OPENWRT:=$(PACKAGE_DIR)/base-files-$(BOARD)_$(PKG_RELEASE)_$(ARCH).ipk

$(PKG_BUILD_DIR)/.prepared:
	mkdir -p $(PKG_BUILD_DIR)
	touch $@

$(PKG_BUILD_DIR)/jffs2root: jffs2root.c
	$(TARGET_CC) -o $@ $<

$(PKG_BUILD_DIR)/.built: $(PKG_BUILD_DIR)/jffs2root
	touch $@
	
$(IPKG_OPENWRT): $(PKG_BUILD_DIR)/jffs2root
	$(SCRIPT_DIR)/make-ipkg-dir.sh $(IDIR_OPENWRT) ipkg/base-files-arch.control $(PKG_RELEASE) $(ARCH)
	$(SED) s,base-files-arch,base-files-$(BOARD),g $(IDIR_OPENWRT)/CONTROL/control
	mkdir -p $(IDIR_OPENWRT)/sbin
	cp $(PKG_BUILD_DIR)/jffs2root $(IDIR_OPENWRT)/sbin
	$(RSTRIP) $(IDIR_OPENWRT)
	$(IPKG_BUILD) $(IDIR_OPENWRT) $(PACKAGE_DIR)

install: compile
	$(IPKG) install $(IPKG_OPENWRT)

compile: install-dev $(IPKG_OPENWRT)
install-dev:
	mkdir -p $(STAGING_DIR)/usr/include
	cp -fpR ./include/[a-z]* $(STAGING_DIR)/usr/include/
