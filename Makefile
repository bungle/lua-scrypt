SCRYPT_VERSION = 0.0.1
LUA_VERSION    = 5.1

# See http://lua-users.org/wiki/BuildingModules for platform specific
# details.

## Linux/BSD
PREFIX ?=          /usr/local
LDFLAGS +=         -shared

## OSX (Macports)
#PREFIX ?=          /opt/local
#LDFLAGS +=         -bundle -undefined dynamic_lookup

LUA_INCLUDE_DIR ?= $(PREFIX)/include
LUA_LIB_DIR ?=     $(PREFIX)/lib/lua/$(LUA_VERSION)

# Some versions of Solaris are missing isinf(). Add -DMISSING_ISINF to
# CFLAGS to work around this bug.

#CFLAGS ?=          -g -Wall -pedantic -fno-inline
CFLAGS ?=          -g -O3 -Wall -pedantic
override CFLAGS += -fpic -I$(LUA_INCLUDE_DIR) -DVERSION=\"$(SCRYPT_VERSION)\"

INSTALL ?= install

.PHONY: all clean install package

all: scrypt.so

scrypt.so: crypto_scrypt-sse.o memlimit.o scrypt_calibrate.o scryptenc_cpuperf.o sha256.o
	$(CC) $(LDFLAGS) -o $@ $^

install:
	$(INSTALL) -d $(DESTDIR)/$(LUA_LIB_DIR)
	$(INSTALL) scrypt.so $(DESTDIR)/$(LUA_LIB_DIR)

clean:
	rm -f *.o *.so

package:
	git archive --prefix="lua-scrypt-$(SCRYPT_VERSION)/" master | \
		gzip -9 > "lua-scrypt-$(SCRYPT_VERSION).tar.gz"
	git archive --prefix="lua-scrypt-$(SCRYPT_VERSION)/" \
		-o "lua-scrypt-$(SCRYPT_VERSION).zip" master
