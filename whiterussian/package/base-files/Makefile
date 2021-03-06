# $Id: Makefile 5602 2006-11-21 14:17:17Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=base-files
PKG_RELEASE:=11
PKG_BUILD_DIR:=$(BUILD_DIR)/base-files

include $(TOPDIR)/package/rules.mk

IDIR_BASE:=$(PKG_BUILD_DIR)/base-files
IPKG_BASE:=$(PACKAGE_DIR)/$(PKG_NAME)_$(PKG_RELEASE)_$(ARCH).ipk

LIBC_VERSION:=${shell cat $(STAGING_DIR)/uclibc_version}
IDIR_LIBC:=$(PKG_BUILD_DIR)/uclibc
IPKG_LIBC:=$(PACKAGE_DIR)/uclibc_$(LIBC_VERSION)-$(PKG_RELEASE)_$(ARCH).ipk

GCC_VERSION:=${shell cat $(STAGING_DIR)/gcc_version}
IDIR_GCC:=$(PKG_BUILD_DIR)/libgcc
IPKG_GCC:=$(PACKAGE_DIR)/libgcc_$(GCC_VERSION)-$(PKG_RELEASE)_$(ARCH).ipk

PACKAGES:=$(IPKG_BASE) $(IPKG_LIBC) 
PACKAGES_INSTALL:=$(IPKG_BASE) $(IPKG_LIBC) 

ifeq ($(BR2_PACKAGE_LIBGCC),y)
PACKAGES+=$(IPKG_GCC)
PACKAGES_INSTALL+=$(IPKG_GCC)
endif
ifeq ($(BR2_PACKAGE_LIBGCC),m)
PACKAGES+=$(IPKG_GCC)
endif

$(PKG_BUILD_DIR)/.prepared:
	mkdir -p $(PKG_BUILD_DIR) $(PACKAGE_DIR)
	touch $@

$(PKG_BUILD_DIR)/.built:
	touch $@

$(IPKG_BASE):
	$(SCRIPT_DIR)/make-ipkg-dir.sh $(IDIR_BASE) ipkg/$(PKG_NAME).control $(PKG_RELEASE) $(ARCH)
	$(CP) ./default/* $(IDIR_BASE)
	mkdir -p $(IDIR_BASE)/dev
	mkdir -p $(IDIR_BASE)/etc/crontabs
	mkdir -p $(IDIR_BASE)/jffs
	mkdir -p $(IDIR_BASE)/lib
	mkdir -p $(IDIR_BASE)/mnt
	mkdir -p $(IDIR_BASE)/proc
	mkdir -p $(IDIR_BASE)/tmp
	mkdir -p $(IDIR_BASE)/usr/lib
	mkdir -p $(IDIR_BASE)/usr/bin
	mkdir -p $(IDIR_BASE)/www
	rm -f $(IDIR_BASE)/var
	rm -f $(IDIR_BASE)/etc/resolv.conf
	ln -sf /tmp/resolv.conf $(IDIR_BASE)/etc/resolv.conf
	ln -sf /tmp $(IDIR_BASE)/var
	-find $(IDIR_BASE) -type d -name CVS | xargs rm -rf
	-find $(IDIR_BASE) -type d -name .svn | xargs rm -rf
	-find $(IDIR_BASE) -name '.#*' | xargs rm -f
	$(IPKG_BUILD) $(IDIR_BASE) $(PACKAGE_DIR)

$(IPKG_LIBC):
	$(SCRIPT_DIR)/make-ipkg-dir.sh $(IDIR_LIBC) ipkg/uclibc.control $(LIBC_VERSION)-$(PKG_RELEASE) $(ARCH)
	mkdir -p $(IDIR_LIBC)/lib
	for file in ld-uClibc libc libcrypt libdl libm libnsl libresolv librt libuClibc libutil; do \
		$(CP) $(STAGING_DIR)/lib/$$file.so.* $(IDIR_LIBC)/lib/; \
		$(CP) $(STAGING_DIR)/lib/$$file-$(LIBC_VERSION).so $(IDIR_LIBC)/lib/; \
	done
	-$(STRIP) $(IDIR_LIBC)/lib/*
	$(IPKG_BUILD) $(IDIR_LIBC) $(PACKAGE_DIR)

$(IPKG_GCC):
	$(SCRIPT_DIR)/make-ipkg-dir.sh $(IDIR_GCC) ipkg/libgcc.control $(GCC_VERSION)-$(PKG_RELEASE) $(ARCH)
	mkdir -p $(IDIR_GCC)/lib
	$(CP) $(STAGING_DIR)/lib/libgcc_s.so.* $(IDIR_GCC)/lib/
	-$(STRIP) $(IDIR_GCC)/lib/*
	$(IPKG_BUILD) $(IDIR_GCC) $(PACKAGE_DIR)

$(PACKAGE_DIR):
	mkdir -p $@

package-clean:
	rm -f $(PACKAGES)
clean: package-clean
prepare: 
compile: $(PACKAGES)
install: compile
	mkdir -p $(TARGET_DIR)
	$(IPKG) install $(PACKAGES_INSTALL)
