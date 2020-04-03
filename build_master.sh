#!/bin/bash

if [[ "${1}" != "skip" ]] ; then
	git reset --hard
	git clean -fdx
	./build_kernel.sh stock "$@" || exit 1
fi

VERSION="$(cat version)-$(date +%F | sed s@-@@g)"

if [ -e boot.img ] ; then
	rm arter97-kernel-$VERSION.zip 2>/dev/null
	cp boot.img arter97-kernel-$VERSION.img

	# Pack AnyKernel3
	rm -rf kernelzip
	mkdir kernelzip
	echo "
kernel.string=arter97 kernel $(cat version) @ xda-developers
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=phoenix
device.name2=phoenixin
block=/dev/block/bootdevice/by-name/boot
is_slot_device=0
ramdisk_compression=gzip
" > kernelzip/props
	cp -rp ~/android/anykernel/* kernelzip/
	cd kernelzip/
	7z a -mx9 arter97-kernel-$VERSION-tmp.zip *
	7z a -mx0 arter97-kernel-$VERSION-tmp.zip ../arch/arm64/boot/Image.gz-dtb
	zipalign -v 4 arter97-kernel-$VERSION-tmp.zip ../arter97-kernel-$VERSION.zip
	rm arter97-kernel-$VERSION-tmp.zip
	cd ..
	ls -al arter97-kernel-$VERSION.zip
fi
