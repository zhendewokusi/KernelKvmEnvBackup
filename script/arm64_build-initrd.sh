#!/bin/sh

KERNEL=~/kernel
BUSYBOX=~/kernel/busybox-1.36.1
LINUX=~/kernel/linux

cd "$BUSYBOX/_install" || exit 1
find . | cpio -o --format=newc > "$KERNEL/rootfs.img"
cd "$KERNEL" || exit 1
gzip -c rootfs.img > ~/kernel/arm64/rootfs.img.gz
# gzip -c rootfs.img > ~/kernel/rootfs.img.gz

