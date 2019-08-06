linux/src:
	mkdir -pv linux/src
	cd linux && wget -c -nv https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.2.6.tar.xz
	cd linux && tar xf linux-*.xz -C src --strip-components 1
	cd linux && rm -v linux-*.xz
linux/conf: linux/src
	mkdir -pv linux/conf
	cd linux/src && $(MAKE) O=../conf tinyconfig
	cd linux/conf && ../src/scripts/kconfig/merge_config.sh .config ../../assets/linux.conf
	cd linux/conf && $(MAKE)
linux/out: linux/conf
	mkdir -pv linux/out/{boot,root}
	cp -av assets/startup.nsh linux/out/boot
	cd linux/conf && INSTALL_PATH=../out/boot $(MAKE) install
	cd linux/conf && $(MAKE) headers_install INSTALL_HDR_PATH=../out/root

glibc/src:
	mkdir -pv glibc/src
	cd glibc && wget -c -nv https://ftp.acc.umu.se/mirror/gnu.org/gnu/glibc/glibc-2.30.tar.xz
	cd glibc && tar xf glibc-*.xz -C src --strip-components 1
	cd glibc && rm glibc-*.xz
glibc/conf: glibc/src linux/out
	$(eval INCLUDE1 := $(shell cd linux/out/root/include && pwd))
	mkdir -pv glibc/conf
	cd glibc/conf && ../src/configure --prefix= --enable-kernel=4.14 --disable-profile --with-headers=$(INCLUDE1)
	cd glibc/conf && $(MAKE)
glibc/out: glibc/conf
	$(eval DESTDIR1 := $(shell pwd)/glibc/out/root)
	mkdir -pv glibc/out/root
	export DESTDIR=$(DESTDIR1) && cd glibc/conf && $(MAKE) install
	cd glibc && touch out

libcap/src:
	mkdir -pv libcap/src
	cd libcap && wget -c -nv https://mirrors.edge.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.27.tar.xz
	cd libcap && tar xf libcap-*.xz -C src --strip-components 1
	cd libcap && rm libcap-*.xz
libcap/conf: libcap/src
	cp -av libcap/src libcap/conf
	cd libcap/conf && sed -i '/install.*STALIBNAME/d' libcap/Makefile
	cd libcap/conf && $(MAKE)
libcap/out: libcap/conf
	$(eval DESTDIR2 := $(shell pwd)/libcap/out/root)
	mkdir -pv libcap/out/root
	cd libcap/conf && make RAISE_SETFCAP=no lib=lib prefix= install DESTDIR=$(DESTDIR2)

readline/src:
	mkdir -pv readline/src
	cd readline && wget -c -nv https://ftp.acc.umu.se/mirror/gnu.org/gnu/readline/readline-8.0.tar.gz
	cd readline && tar xf readline-*.gz -C src --strip-components 1
	cd readline && rm readline-*.gz
readline/conf: readline/src
	mkdir -pv readline/conf
	cd readline/conf && ../src/configure --prefix=
	cd readline/conf && $(MAKE)
readline/out: readline/conf
	$(eval DESTDIR3 := $(shell pwd)/readline/out/root/)
	mkdir -pv readline/out/root
	cd readline/conf && $(MAKE) install DESTDIR=$(DESTDIR3)

ncurses/src:
	mkdir -pv ncurses/src
	cd ncurses && wget -c -nv https://ftp.acc.umu.se/mirror/gnu.org/gnu/ncurses/ncurses-6.1.tar.gz
	cd ncurses && tar xf ncurses-*.gz -C src --strip-components 1
	cd ncurses && rm ncurses-*.gz
ncurses/conf: ncurses/src
	mkdir -pv ncurses/conf
	cd ncurses/conf && ../src/configure --prefix= --enable-widec --without-normal --with-shared --without-debug
	cd ncurses/conf && $(MAKE)
ncurses/out: ncurses/conf
	$(eval DESTDIR4 := $(shell pwd)/ncurses/out/root/)
	mkdir -pv ncurses/out/root
	cd ncurses/conf && $(MAKE) install DESTDIR=$(DESTDIR4)
	cd ncurses && touch out

bash/src:
	mkdir -pv bash/src
	cd bash && wget -c -nv https://ftp.acc.umu.se/mirror/gnu.org/gnu/bash/bash-5.0.tar.gz
	cd bash && tar xf bash-*.gz -C src --strip-components 1
	cd bash && rm bash-*.gz
bash/conf: bash/src readline/out
	mkdir -pv bash/conf
	cd bash/conf && ../src/configure --prefix= --without-bash-malloc --with-installed-readline=../../readline/out/root
	cd bash/conf && $(MAKE)
bash/out: bash/conf
	$(eval DESTDIR5 := $(shell pwd)/bash/out/root/)
	mkdir -pv bash/out/root
	cd bash/conf && $(MAKE) install DESTDIR=$(DESTDIR5)

coreutils/src:
	mkdir -pv coreutils/src
	cd coreutils && wget -c -nv https://ftp.acc.umu.se/mirror/gnu.org/gnu/coreutils/coreutils-8.30.tar.xz
	cd coreutils && tar xf coreutils-*.xz -C src --strip-components 1
	cd coreutils && rm coreutils-*.xz
	cd coreutils/src && autoreconf -fiv
coreutils/conf: coreutils/src
	mkdir -pv coreutils/conf
	cd coreutils/conf && ../src/configure --prefix=
	cd coreutils/conf && $(MAKE)
coreutils/out: coreutils/conf
	$(eval DESTDIR6 := $(shell pwd)/coreutils/out/root/)
	mkdir -pv coreutils/out/root
	cd coreutils/conf && $(MAKE) install DESTDIR=$(DESTDIR6)

util-linux/src:
	mkdir -pv util-linux/src
	cd util-linux && wget -c -nv https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.34/util-linux-2.34.tar.xz
	cd util-linux && tar xf util-linux-*.xz -C src --strip-components 1
	cd util-linux && rm util-linux-*.xz
util-linux/conf: util-linux/src
	mkdir -pv util-linux/conf
	cd util-linux/conf && ../src/configure --prefix= --disable-static --without-python --without-systemd --without-systemdsystemunitdir --disable-makeinstall-chown
	cd util-linux/conf && $(MAKE)
util-linux/out: util-linux/conf
	$(eval DESTDIR7 := $(shell pwd)/util-linux/out/root/)
	mkdir -pv util-linux/out/root
	cd util-linux/conf && $(MAKE) install DESTDIR=$(DESTDIR7)

partdirs: linux/out glibc/out libcap/out readline/out ncurses/out bash/out coreutils/out util-linux/out
	mkdir -pv partdirs/root/{boot,dev,proc,sys}
	cd partdirs/root && ln -s lib lib64
	cp -av linux/out/boot partdirs/
	cp -av */out/root partdirs/

sl2.gpt: partdirs
	dd if=/dev/zero of=sl2.esp bs=512 count=30720
	mkfs.fat -F 16 sl2.esp
	mcopy -s -i sl2.esp partdirs/boot/* ::/
	mksquashfs partdirs/root/ sl2.sqsh -all-root
	dd if=/dev/zero of=sl2.gpt bs=512 count=262144
	sgdisk -og --disk-guid=R sl2.gpt
	sgdisk -n 1:0:16M -c 1:"ESP Linux EFISTUB" -t 1:EF00 sl2.gpt
	sgdisk -N 2 -c 2:"Shoreline root FS" -t 2:8304 sl2.gpt
	dd if=sl2.esp of=sl2.gpt bs=512 seek=2048 conv=notrunc
	dd if=sl2.sqsh of=sl2.gpt bs=512 seek=34816 conv=notrunc
	rm *.esp *.sqsh
