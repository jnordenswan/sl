clean:
	git clean -dfx

linux/src:
	mkdir -pv linux/src
	cd linux && wget -c -nv https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.7.tar.xz
	cd linux && tar xf linux-*.xz -C src --strip-components 1
	cd linux && rm -v linux-*.xz
linux/conf: linux/src
	mkdir -pv linux/conf
	cd linux/src && $(MAKE) O=../conf defconfig
	cd linux/conf && ../src/scripts/kconfig/merge_config.sh .config ../../assets/linux.conf
	cd linux/conf && $(MAKE)
linux/out: linux/conf
	mkdir -pv linux/out/{boot,root}
	cp -av assets/startup.nsh linux/out/boot
	cd linux/conf && INSTALL_PATH=../out/boot $(MAKE) install
	cd linux/conf && $(MAKE) headers_install INSTALL_HDR_PATH=../out/root

pam/src:
	mkdir -pv pam/src
	cd pam && wget -c -nv https://github.com/linux-pam/linux-pam/releases/download/v1.5.2/Linux-PAM-1.5.2.tar.xz
	cd pam && tar xf Linux-PAM-*.tar.xz -C src --strip-components 1
	cd pam && rm -v Linux-PAM-*.tar.xz
pam/conf: pam/src
	mkdir -pv pam/conf
	cd pam/conf && ../src/configure --prefix=
	cd pam/conf && $(MAKE)
pam/out: pam/conf
	$(eval DESTDIR0 := $(shell pwd)/pam/out/root)
	mkdir -pv pam/out/root
	export DESTDIR=$(DESTDIR0) && cd pam/conf && $(MAKE) install
	cd pam && touch out

glibc/src:
	mkdir -pv glibc/src
	cd glibc && wget -c -nv https://ftp.acc.umu.se/mirror/gnu.org/gnu/glibc/glibc-2.34.tar.xz
	cd glibc && tar xf glibc-*.xz -C src --strip-components 1
	cd glibc && rm glibc-*.xz
glibc/conf: glibc/src linux/out
	$(eval INCLUDE1 := $(shell cd linux/out/root/include && pwd))
	mkdir -pv glibc/conf
	cd glibc/conf && ../src/configure --prefix= --enable-kernel=5.14 --disable-profile --with-headers=$(INCLUDE1)
	cd glibc/conf && $(MAKE)
glibc/out: glibc/conf
	$(eval DESTDIR1 := $(shell pwd)/glibc/out/root)
	mkdir -pv glibc/out/root
	export DESTDIR=$(DESTDIR1) && cd glibc/conf && $(MAKE) install
	cd glibc && touch out

libcap/src:
	mkdir -pv libcap/src
	cd libcap && wget -c -nv https://mirrors.edge.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.62.tar.xz
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
	cd readline && wget -c -nv https://ftp.acc.umu.se/mirror/gnu.org/gnu/readline/readline-8.1.tar.gz
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
	cd ncurses && wget -c -nv https://ftp.acc.umu.se/mirror/gnu.org/gnu/ncurses/ncurses-6.3.tar.gz
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
	cd bash && wget -c -nv https://ftp.acc.umu.se/mirror/gnu.org/gnu/bash/bash-5.1.8.tar.gz
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
	cd coreutils && wget -c -nv https://ftp.acc.umu.se/mirror/gnu.org/gnu/coreutils/coreutils-9.0.tar.xz
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
	cd util-linux && wget -c -nv https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.37/util-linux-2.37.2.tar.xz
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

udev/src:
	mkdir -pv udev/src
	cd udev && wget -c -nv https://github.com/eudev-project/eudev/archive/refs/tags/v3.2.10.tar.gz
	cd udev && tar xf *.tar.gz -C src --strip-components 1
	cd udev && rm *.tar.gz
	-cd udev/src && ./autogen.sh 
udev/conf: udev/src
	mkdir -pv udev/conf
	cd udev/conf && ../src/configure --prefix= --disable-kmod
	cd udev/conf && $(MAKE)
udev/out: udev/conf
	$(eval DESTDIR8 := $(shell pwd)/udev/out/root/)
	mkdir -pv udev/out/root
	cd udev/conf && $(MAKE) install DESTDIR=$(DESTDIR8)
	cd udev && touch out

acl/src:
	mkdir -pv acl/src
	cd acl && wget -c -nv https://git.savannah.nongnu.org/cgit/acl.git/snapshot/acl-2.3.1.tar.gz
	cd acl && tar xf *.tar.gz -C src --strip-components 1
	cd acl && rm *.tar.gz
	cd acl/src && ./autogen.sh
acl/conf: acl/src
	mkdir -pv acl/conf
	cd acl/conf && ../src/configure --prefix=
	cd acl/conf && $(MAKE)
acl/out: acl/conf
	$(eval DESTDIR9 := $(shell pwd)/acl/out/root/)
	mkdir -pv acl/out/root
	cd acl/conf && $(MAKE) install DESTDIR=$(DESTDIR9)

attr/src:
	mkdir -pv attr/src
	cd attr && wget -c -nv https://git.savannah.nongnu.org/cgit/attr.git/snapshot/attr-2.5.1.tar.gz
	cd attr && tar xf *.tar.gz -C src --strip-components 1
	cd attr && rm *.tar.gz
	cd attr/src && ./autogen.sh
attr/conf: attr/src
	mkdir -pv attr/conf
	cd attr/conf && ../src/configure --prefix=
	cd attr/conf && $(MAKE)
attr/out: attr/conf
	$(eval DESTDIR10 := $(shell pwd)/attr/out/root/)
	mkdir -pv attr/out/root
	cd attr/conf && $(MAKE) install DESTDIR=$(DESTDIR10)

skarnet/src:
	mkdir -pv skarnet/src
	cd skarnet/src && wget -c -nv https://skarnet.org/software/skalibs/skalibs-2.11.0.0.tar.gz https://skarnet.org/software/execline/execline-2.8.1.0.tar.gz https://skarnet.org/software/s6/s6-2.11.0.0.tar.gz
	# cd skalibs && tar xf *.tar.gz -C src --strip-components 1
skarnet/conf: skarnet/src
	mkdir -pv skarnet/conf
	mkdir -pv skarnet/stage
	$(eval SKASTAGE := $(shell pwd)/skarnet/stage/)
	cd skarnet/conf && cat ../src/*.tar.gz | tar xfz - -i
skarnet/stage: skarnet/conf
	cd skarnet/conf/skalibs* && ./configure && $(MAKE) install DESTDIR=$(SKASTAGE)
	cd skarnet/conf/execline* && ./configure --libdir=/usr/lib/skalibs --with-sysdeps=$(SKASTAGE)usr/lib/skalibs/sysdeps/ --with-include=$(SKASTAGE)usr/include/ --with-lib=$(SKASTAGE)lib/ && $(MAKE) install DESTDIR=$(SKASTAGE)
	cd skarnet/conf/s6* && ./configure --with-sysdeps=$(SKASTAGE)usr/lib/skalibs/sysdeps/ --with-include=$(SKASTAGE)usr/include/ --with-lib=$(SKASTAGE)usr/lib/skalibs/ --with-dynlib=$(SKASTAGE)lib/ && $(MAKE) install DESTDIR=$(SKASTAGE)
skarnet/out: skarnet/stage
	cd skarnet && mv stage root && mkdir out && mv root out

nano/src:
	mkdir -pv nano/src
	cd nano/src && wget -c -nv https://www.nano-editor.org/dist/v5/nano-5.9.tar.xz
nano/conf: nano/src
	mkdir -pv nano/conf
	cd nano/src && tar xf *.tar.xz -C ../conf --strip-components=1
	cd nano/conf && ./configure --prefix= --disable-libmagic
nano/out: nano/conf
	$(eval NANOROOT := $(shell pwd)/nano/stage/root/)
	mkdir -pv nano/stage/root
	cd nano/conf && $(MAKE) && $(MAKE) install DESTDIR=$(NANOROOT)
	mv nano/stage nano/out

zlib/src:
	mkdir -pv zlib/src && cd zlib/src && wget -c -nv https://www.zlib.net/zlib-1.2.11.tar.xz
zlib/conf: zlib/src
	mkdir -pv zlib/conf
	cd zlib/src && tar xf *.tar.xz -C ../conf --strip-components=1
	cd zlib/conf && ./configure --prefix=
zlib/out: zlib/conf
	$(eval ZLIBROOT := $(shell pwd)/zlib/stage/root/)
	mkdir -pv zlib/stage
	cd zlib/conf && $(MAKE) && $(MAKE) install DESTDIR=$(ZLIBROOT)
	mv zlib/stage zlib/out

audit/src:
	mkdir -pv audit/src && cd audit/src && wget -c -nv https://people.redhat.com/sgrubb/audit/audit-3.0.6.tar.gz
audit/conf: audit/src
	mkdir -pv audit/conf
	cd audit/src && tar xf *.tar.gz -C ../conf --strip-components=1
	cd audit/conf && ./configure --prefix= --without-python --without-python3 --without-golang
audit/out: audit/conf
	$(eval AUDITROOT := $(shell pwd)/audit/stage/root/)
	mkdir -pv audit/stage
	cd audit/conf && $(MAKE) && $(MAKE) install DESTDIR=$(AUDITROOT)
	mv audit/stage audit/out

root/out:
	mkdir -pv root/out/root/root
	cd root/out/root/root && printf -- 'alias dir="ls -lhAtr --color=auto --group-directories-first"\nmount proc -t proc /proc\nmount sys -t sysfs /sys\nmount -o ro /dev/sda1 /boot\nmount tmpfs -t tmpfs /tmp\nmkdir /tmp/{run-upper,run-work,etc-upper,etc-work}\nmount -t overlay overlay -o lowerdir=/run,upperdir=/tmp/run-upper,workdir=/tmp/run-work /run\nmount -t overlay overlay -o lowerdir=/etc,upperdir=/tmp/etc-upper,workdir=/tmp/etc-work /etc\nudevadm hwdb --update\nudevadm settle\nudevd -D &\n' > init.sh

partdirs: linux/out pam/out glibc/out libcap/out readline/out ncurses/out bash/out coreutils/out util-linux/out udev/out acl/out attr/out skarnet/out nano/out zlib/out audit/out root/out
	mkdir -pv partdirs/root/{boot,dev,proc,sys,mnt,tmp,run}
	cd partdirs/root && ln -s lib lib64
	cp -av linux/out/boot partdirs/
	cp -av */out/root partdirs/

sl2.gpt: partdirs
	dd if=/dev/zero of=sl2.esp bs=512 count=30720
	mkfs.fat -F 16 sl2.esp
	mcopy -s -i sl2.esp partdirs/boot/* ::/
	mksquashfs partdirs/root/ sl2.sqsh -all-root -b 1M
	dd if=/dev/zero of=sl2.gpt bs=512 count=262144
	sgdisk -og --disk-guid=R sl2.gpt
	sgdisk -n 1:0:16M -c 1:"ESP Linux EFISTUB" -t 1:EF00 sl2.gpt
	sgdisk -N 2 -c 2:"Shoreline root FS" -t 2:8304 sl2.gpt
	dd if=sl2.esp of=sl2.gpt bs=512 seek=2048 conv=notrunc
	dd if=sl2.sqsh of=sl2.gpt bs=512 seek=34816 conv=notrunc
	rm *.esp *.sqsh
