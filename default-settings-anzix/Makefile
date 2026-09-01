include $(TOPDIR)/rules.mk

PKG_NAME:=default-settings-anzix
PKG_VERSION:=1
PKG_RELEASE:=1
PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/default-settings-anzix
	SECTION:=luci
	CATEGORY:=LuCI
	TITLE:=My Default Settings
	PKGARCH:=all
	DEPENDS:=+luci
endef

define Package/default-settings-anzix/description
	My Default Settings.
endef

# This is a pure config package, no compilation needed
define Build/Compile
endef

define Package/default-settings-anzix/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/zzz-default-settings $(1)/etc/uci-defaults/zzz-default-settings
endef

$(eval $(call BuildPackage,default-settings-anzix))
