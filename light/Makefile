linux/src:
	mkdir -pv linux/src
	cd linux && wget -c -nv https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.14.79.tar.xz
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

musl/src:
	mkdir -pv musl/src
	cd musl && wget -c -nv https://www.musl-libc.org/releases/musl-1.1.20.tar.gz
	cd musl && tar xf musl-*.tar.gz -C src --strip-components 1
	cd musl && rm musl-*.tar.gz
musl/conf: musl/src
	mkdir -pv musl/conf
	cd musl/conf && ../src/configure --prefix=../out/root
musl/out: musl/conf
	cd musl/conf && $(MAKE) && $(MAKE) install
	cd musl && touch out

busybox/src:
	mkdir -pv busybox/src
	cd busybox && wget -c -nv https://busybox.net/downloads/busybox-1.29.3.tar.bz2
	cd busybox && tar xf busybox-*.tar.bz2 -C src --strip-components 1
	cd busybox && rm busybox-*.tar.bz2
busybox/conf: busybox/src
	mkdir -pv busybox/conf
	cd busybox/conf && make KBUILD_SRC=../src -f ../src/Makefile allnoconfig
	cp assets/busybox.conf busybox/conf/.config
busybox/out: busybox/conf
	cd busybox/conf && $(MAKE) && $(MAKE) install
	touch busybox/out

partdirs: linux/out musl/out busybox/out
	mkdir -pv partdirs/root/{boot,dev,proc,sys}
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
