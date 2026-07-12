################################################################################
#
# libtirpc
#
################################################################################

LIBTIRPC_VERSION = 1.3.6
LIBTIRPC_SOURCE = libtirpc-$(LIBTIRPC_VERSION).tar.bz2
LIBTIRPC_SITE = http://downloads.sourceforge.net/project/libtirpc/libtirpc/$(LIBTIRPC_VERSION)
LIBTIRPC_LICENSE = BSD-3-Clause
LIBTIRPC_LICENSE_FILES = COPYING
LIBTIRPC_CPE_ID_VALID = YES

LIBTIRPC_INSTALL_STAGING = YES

# getrpcby{number,name} are only provided if 'GQ' is defined
LIBTIRPC_CONF_ENV = CFLAGS="$(TARGET_CFLAGS) -DGQ"

ifeq ($(BR2_PACKAGE_LIBTIRPC_GSS),y)
LIBTIRPC_CONF_ENV += KRB5_CONFIG=$(STAGING_DIR)/usr/bin/krb5-config
LIBTIRPC_CONF_OPTS += --enable-gssapi
LIBTIRPC_DEPENDENCIES += libkrb5
else
LIBTIRPC_CONF_OPTS += --disable-gssapi
# src/libtirpc.map unconditionally lists GSS-API symbols in its
# version script even when built with --disable-gssapi, so those
# symbols never get defined. GNU ld silently drops unmatched
# version-script entries, but LLD treats that as a hard error unless
# told otherwise.
LIBTIRPC_CONF_ENV += LDFLAGS="-Wl,--undefined-version"
endif
HOST_LIBTIRPC_CONF_OPTS = --disable-gssapi

$(eval $(autotools-package))
$(eval $(host-autotools-package))
