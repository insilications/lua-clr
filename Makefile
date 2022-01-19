# Makefile for installing Lua
# See doc/readme.html for installation and customization instructions.

# == CHANGE THE SETTINGS BELOW TO SUIT YOUR ENVIRONMENT =======================

# Your platform. See PLATS for possible values.
PLAT= guess

# Where to install. The installation starts in the src and doc directories,
# so take care if INSTALL_TOP is not an absolute path. See the local target.
# You may want to make INSTALL_LMOD and INSTALL_CMOD consistent with
# LUA_ROOT, LUA_LDIR, and LUA_CDIR in luaconf.h.
DESTDIR?=
INSTALL_TOP= $(DESTDIR)/usr
INSTALL_BIN= $(INSTALL_TOP)/bin
INSTALL_INC= $(INSTALL_TOP)/include
INSTALL_LIB= $(INSTALL_TOP)/lib64
INSTALL_MAN= $(INSTALL_TOP)/share/man/man1
INSTALL_LMOD= $(INSTALL_TOP)/share/lua/$V
INSTALL_CMOD= $(INSTALL_TOP)/lib/lua/$V
INSTALL_PC= $(INSTALL_LIB)/pkgconfig
PC_IN=lua.pc.in

# How to install. If your install program does not support "-p", then
# you may have to run ranlib on the installed liblua.a.
INSTALL= install -p
INSTALL_EXEC= $(INSTALL) -m 0755
INSTALL_DATA= $(INSTALL) -m 0644
#
# If you don't have "install" you can use "cp" instead.
# INSTALL= cp -p
# INSTALL_EXEC= $(INSTALL)
# INSTALL_DATA= $(INSTALL)

# Other utilities.
MKDIR= mkdir -p
RM= rm -f

# == END OF USER SETTINGS -- NO NEED TO CHANGE ANYTHING BELOW THIS LINE =======

# Convenience platforms targets.
PLATS= guess aix bsd c89 freebsd generic linux linux-readline macosx mingw posix solaris

# What to install.
TO_BIN= lua luac
TO_INC= lua.h luaconf.h lualib.h lauxlib.h lua.hpp
TO_LIB= liblua.a liblua.so.$(R)
TO_MAN= lua.1 luac.1
TO_PC= lua.pc

# Lua version and release.
K= 5.4
R= $K.4

# Targets start here.
all:	$(PLAT)

$(PLATS) help test clean: pc
	cd src && $(MAKE) $@ K=$(K) R=$(R)

test_pgo:      dummy
	src/lua scimark.lua -small
	src/lua_shared scimark.lua -small
	src/lua scimark.lua -large
	src/lua_shared scimark.lua -large

install: dummy
	cd src && $(MKDIR) $(INSTALL_BIN) $(INSTALL_INC) $(INSTALL_LIB) $(INSTALL_MAN) $(INSTALL_LMOD) $(INSTALL_CMOD) $(INSTALL_PC)
	cd src && $(INSTALL_EXEC) $(TO_BIN) $(INSTALL_BIN)
	cd src && $(INSTALL_DATA) $(TO_INC) $(INSTALL_INC)
	cd src && $(INSTALL_DATA) $(TO_LIB) $(INSTALL_LIB)
	cd $(INSTALL_LIB) && ln -sf liblua.so.$(R) liblua.so.$(K) && \
	ln -sf liblua.so.$(R) liblua.so
	cd doc && $(INSTALL_DATA) $(TO_MAN) $(INSTALL_MAN)
	cd src && $(INSTALL_DATA) $(TO_PC)  $(INSTALL_PC)

uninstall:
	cd src && cd $(INSTALL_BIN) && $(RM) $(TO_BIN)
	cd src && cd $(INSTALL_INC) && $(RM) $(TO_INC)
	cd src && cd $(INSTALL_LIB) && $(RM) $(TO_LIB)
	cd doc && cd $(INSTALL_MAN) && $(RM) $(TO_MAN)
	cd src && cd $(INSTALL_PC) && $(RM) $(TO_PC)

local:
	$(MAKE) install INSTALL_TOP=../install

# make may get confused with install/ if it does not support .PHONY.
dummy:

# Echo config parameters.
echo:
	@cd src && $(MAKE) -s echo
	@echo "PLAT= $(PLAT)"
	@echo "V= $V"
	@echo "R= $R"
	@echo "TO_BIN= $(TO_BIN)"
	@echo "TO_INC= $(TO_INC)"
	@echo "TO_LIB= $(TO_LIB)"
	@echo "TO_MAN= $(TO_MAN)"
	@echo "INSTALL_TOP= $(INSTALL_TOP)"
	@echo "INSTALL_BIN= $(INSTALL_BIN)"
	@echo "INSTALL_INC= $(INSTALL_INC)"
	@echo "INSTALL_LIB= $(INSTALL_LIB)"
	@echo "INSTALL_MAN= $(INSTALL_MAN)"
	@echo "INSTALL_LMOD= $(INSTALL_LMOD)"
	@echo "INSTALL_CMOD= $(INSTALL_CMOD)"
	@echo "INSTALL_EXEC= $(INSTALL_EXEC)"
	@echo "INSTALL_DATA= $(INSTALL_DATA)"
	@echo "INSTALL_PC= $(INSTALL_PC)"

# Echo pkg-config data.
pc:
	sed s%##INSTALL_TOP##%$(INSTALL_TOP)% src/$(PC_IN) > src/$(TO_PC) && \
	sed -i s%##INSTALL_LIB##%$(INSTALL_LIB)% src/$(TO_PC) && \
	sed -i s%##R##%$(R)% src/$(TO_PC)

# Targets that do not create files (not all makes understand .PHONY).
.PHONY: all $(PLATS) clean test test_pgo install local none dummy echo pecho lecho

# (end of Makefile)
