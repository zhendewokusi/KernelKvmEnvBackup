#!/bin/sh

KERNEL=~/kernel
BUSYBOX=~/kernel/busybox-1.36.1
LINUX=~/kernel/linux

# 检查是否传递了 ARCH 参数
if [ -z "$1" ]; then
  echo "Usage: $0 <ARCH>"
  echo "ARCH options: arm64, x86"
  exit 1
fi

ARCH=$1
ROOTFS_PATH="$KERNEL/$ARCH"

# 根据 ARCH 设置不同的 busybox 安装目录
if [ "$ARCH" = "arm64" ]; then
  INSTALL_DIR="$BUSYBOX/arm64_install"
elif [ "$ARCH" = "x86" ]; then
  INSTALL_DIR="$BUSYBOX/x86_install"
else
  echo "Unsupported ARCH: $ARCH"
  exit 1
fi

# 切换到相应的 busybox 安装目录
cd "$INSTALL_DIR" || exit 1
echo $INSTALL_DIR
echo $ROOTFS_PATH/rootfs.img
find . | cpio -o --format=newc > "$ROOTFS_PATH/rootfs.img"

cd "$KERNEL" || exit 1

# 生成压缩文件
gzip -c "$ROOTFS_PATH/rootfs.img" > "$ROOTFS_PATH/rootfs.img.gz"
