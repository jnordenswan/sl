all: sl2.gpt

linux/src:
	mkdir -pv linux/src
	cd linux && wget -c -nv https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.16.1.tar.xz
	cd linux && tar xf linux-*.xz -C src --strip-components 1
	cd linux && rm -v linux-*.xz
linux/conf: linux/src
	mkdir -pv linux/conf
	cd linux/src && $(MAKE) O=../conf x86_64_defconfig
	cd linux/conf && ../src/scripts/kconfig/merge_config.sh .config ../../assets/linux.conf
	cd linux/conf && $(MAKE)
linux/out: linux/conf
	mkdir -pv linux/out/{boot,root}
	cp -av assets/startup.nsh linux/out/boot
	cd linux/conf && INSTALL_PATH=../out/boot $(MAKE) install
	cd linux/conf && $(MAKE) headers_install INSTALL_HDR_PATH=../out/root

glibc/src:
	mkdir -pv glibc/src
	cd glibc && wget -c -nv https://ftp.acc.umu.se/mirror/gnu.org/gnu/glibc/glibc-2.27.tar.xz
	cd glibc && tar xf glibc-*.xz -C src --strip-components 1
	cd glibc && rm glibc-*.xz
glibc/conf: glibc/src linux/out
	$(eval INCLUDE := $(shell cd linux/out/root/include && pwd))
	mkdir -pv glibc/conf
	cd glibc/conf && ../src/configure --prefix= --enable-kernel=4.15 --disable-profile --with-headers=$(INCLUDE)
	cd glibc/conf && $(MAKE)
glibc/out: glibc/conf
	$(eval DESTDIR := $(shell pwd)/glibc/out/root)
	mkdir -pv glibc/out/root
	export DESTDIR=$(DESTDIR) && cd glibc/conf && $(MAKE) install

libcap/src:
	mkdir -pv libcap/src
	cd libcap && wget -c -nv https://mirrors.edge.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.25.tar.xz
	cd libcap && tar xf libcap-*.xz -C src --strip-components 1
	cd libcap && rm libcap-*.xz
libcap/conf: libcap/src
	-sudo pacman --noconfirm -Rsnc gperf
	cp -av libcap/src libcap/conf
	cd libcap/conf && sed -i '/install.*STALIBNAME/d' libcap/Makefile && $(MAKE)
	sudo pacman --noconfirm -S gperf
libcap/out: libcap/conf
	$(eval DESTDIR := $(shell pwd)/libcap/out/root)
	mkdir -pv libcap/out/root
	cd libcap/conf && make RAISE_SETFCAP=no lib=lib prefix= install DESTDIR=$(DESTDIR)

readline/src:
	mkdir -pv readline/src
	cd readline && wget -c -nv https://ftp.acc.umu.se/mirror/gnu.org/gnu/readline/readline-7.0.tar.gz
	cd readline && tar xf readline-*.gz -C src --strip-components 1
	cd readline && rm readline-*.gz
readline/conf: readline/src
	mkdir -pv readline/conf
	cd readline/conf && ../src/configure --prefix=
	cd readline/conf && $(MAKE)
readline/out: readline/conf
	$(eval DESTDIR := $(shell pwd)/readline/out/root/)
	mkdir -pv readline/out/root
	cd readline/conf && $(MAKE) install DESTDIR=$(DESTDIR)

ncurses/src:
	mkdir -pv ncurses/src
	cd ncurses && wget -c -nv https://ftp.acc.umu.se/mirror/gnu.org/gnu/ncurses/ncurses-6.1.tar.gz
	cd ncurses && tar xf ncurses-*.gz -C src --strip-components 1
	cd ncurses && rm ncurses-*.gz
ncurses/conf: ncurses/src
	mkdir -pv ncurses/conf
	cd ncurses/conf && ../src/configure --prefix= --enable-widec --without-normal --with-shared --woithout-debug
	cd ncurses/conf && $(MAKE)
ncurses/out: ncurses/conf
	$(eval DESTDIR := $(shell pwd)/ncurses/out/root/)
	mkdir -pv ncurses/out/root
	cd ncurses/conf && $(MAKE) install DESTDIR=$(DESTDIR)

bash/src:
	mkdir -pv bash/src
	cd bash && wget -c -nv https://ftp.acc.umu.se/mirror/gnu.org/gnu/bash/bash-4.4.18.tar.gz
	cd bash && tar xf bash-*.gz -C src --strip-components 1
	cd bash && rm bash-*.gz
bash/conf: bash/src readline/out
	mkdir -pv bash/conf
	cd bash/conf && ../src/configure --prefix= --without-bash-malloc --with-installed-readline=../../readline/out/root
	cd bash/conf && $(MAKE)
bash/out: bash/conf
	$(eval DESTDIR := $(shell pwd)/bash/out/root/)
	mkdir -pv bash/out/root
	cd bash/conf && $(MAKE) install DESTDIR=$(DESTDIR)

coreutils/src:
	mkdir -pv coreutils
	cd coreutils && git clone --depth 1 git://git.sv.gnu.org/coreutils
	cd coreutils && mv coreutils src
	cd coreutils/src && ./bootstrap
coreutils/conf: coreutils/src
	mkdir -pv coreutils/conf
	cd coreutils/conf && ../src/configure --prefix= --without-libcap
	cd coreutils/conf && $(MAKE)
coreutils/out: coreutils/conf
	$(eval DESTDIR := $(shell pwd)/coreutils/out/root/)
	mkdir -pv coreutils/out/root
	cd coreutils/conf && $(MAKE) install DESTDIR=$(DESTDIR)

partdirs: linux/out glibc/out libcap/out readline/out ncurses/out bash/out coreutils/out
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
