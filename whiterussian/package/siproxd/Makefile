#
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=siproxd
PKG_VERSION:=0.6.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/siproxd
PKG_MD5SUM:=8dcc0b29e68d495e040f867207074bc1
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,SIPROXD,siproxd,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib" \
		./configure \
		  --target=$(GNU_TARGET_NAME) \
		  --host=$(GNU_TARGET_NAME) \
		  --build=$(GNU_HOST_NAME) \
		  --program-prefix="" \
		  --program-suffix="" \
		  --prefix=/usr \
		  --exec-prefix=/usr \
		  --bindir=/usr/bin \
		  --datadir=/usr/share \
		  --includedir=/usr/include \
		  --infodir=/usr/share/info \
		  --libdir=/usr/lib \
		  --libexecdir=/usr/lib \
		  --localstatedir=/var \
		  --mandir=/usr/share/man \
		  --sbindir=/usr/sbin \
		  --sysconfdir=/etc \
		  $(DISABLE_LARGEFILE) \
		  $(DISABLE_NLS) \
		  --enable-shared \
	);
	touch $@

$(PKG_BUILD_DIR)/.built:
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		SUBDIRS="src scripts contrib" \
		all install
	touch $@

$(IPKG_SIPROXD):
	install -d -m0755 $(IDIR_SIPROXD)/etc
	$(CP) $(PKG_BUILD_DIR)/doc/siproxd.conf.example $(IDIR_SIPROXD)/etc/siproxd.conf
	$(CP) $(PKG_BUILD_DIR)/doc/siproxd_passwd.cfg $(IDIR_SIPROXD)/etc/
	install -d -m0755 $(IDIR_SIPROXD)/etc/init.d
	install -m0755 files/siproxd.init $(IDIR_SIPROXD)/etc/init.d/siproxd
	install -d -m0755 $(IDIR_SIPROXD)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/siproxd $(IDIR_SIPROXD)/usr/sbin/
	$(RSTRIP) $(IDIR_SIPROXD)
	$(IPKG_BUILD) $(IDIR_SIPROXD) $(PACKAGE_DIR)
