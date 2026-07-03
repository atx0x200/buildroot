################################################################################
#
# libzlib
#
################################################################################

LIBZLIB_VERSION = 1.3.1
LIBZLIB_SOURCE = zlib-$(LIBZLIB_VERSION).tar.xz
LIBZLIB_SITE = https://www.zlib.net
LIBZLIB_LICENSE = Zlib
LIBZLIB_LICENSE_FILES = LICENSE
LIBZLIB_INSTALL_STAGING = YES
LIBZLIB_PROVIDES = zlib
LIBZLIB_CPE_ID_VENDOR = zlib
LIBZLIB_CPE_ID_PRODUCT = zlib

# It is not possible to build only a shared version of zlib, so we build both
# shared and static, unless we only want the static libs, and we eventually
# selectively remove what we do not want
ifeq ($(BR2_STATIC_LIBS),y)
LIBZLIB_PIC =
LIBZLIB_SHARED = --static
else
LIBZLIB_PIC = -fPIC
LIBZLIB_SHARED = --shared
endif

# hexagon-unknown-linux-musl's ld.lld errors out (unlike GNU ld, which just
# warns) when a --version-script assigns a version to a symbol that isn't
# defined in the object being linked. zlib's configure "checking for shared
# library support" test hits exactly that: it links a trivial one-function
# test object against the real zlib.map, which lists the full zlib API, so
# the link fails and configure silently falls back to building only the
# static library. Ask lld to tolerate this the way GNU ld does by default.
ifeq ($(BR2_hexagon),y)
LIBZLIB_LDSHARED = LDSHARED="$(TARGET_CC) -shared -Wl,-soname,libz.so.1,--version-script,zlib.map -Wl,--undefined-version"
endif

define LIBZLIB_CONFIGURE_CMDS
	(cd $(@D); rm -rf config.cache; \
		$(TARGET_CONFIGURE_ARGS) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) $(LIBZLIB_PIC)" \
		$(LIBZLIB_LDSHARED) \
		./configure \
		$(LIBZLIB_SHARED) \
		--prefix=/usr \
	)
endef

define HOST_LIBZLIB_CONFIGURE_CMDS
	(cd $(@D); rm -rf config.cache; \
		$(HOST_CONFIGURE_ARGS) \
		$(HOST_CONFIGURE_OPTS) \
		./configure \
		--prefix="$(HOST_DIR)" \
		--sysconfdir="$(HOST_DIR)/etc" \
	)
endef

define LIBZLIB_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D)
endef

define HOST_LIBZLIB_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE1) -C $(@D)
endef

define LIBZLIB_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR=$(STAGING_DIR) LDCONFIG=true install
endef

define LIBZLIB_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR=$(TARGET_DIR) LDCONFIG=true install
endef

# We don't care removing the .a from target, since it not used at link
# time to build other packages, and it is anyway removed later before
# assembling the filesystem images anyway.
ifeq ($(BR2_SHARED_LIBS),y)
define LIBZLIB_RM_STATIC_STAGING
	rm -f $(STAGING_DIR)/usr/lib/libz.a
endef
LIBZLIB_POST_INSTALL_STAGING_HOOKS += LIBZLIB_RM_STATIC_STAGING
endif

define HOST_LIBZLIB_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE1) -C $(@D) LDCONFIG=true install
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
