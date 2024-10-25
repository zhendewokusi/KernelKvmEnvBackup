# have bug

#!/bin/sh

KERNEL=~/kernel
BUSYBOX=~/kernel/busybox-1.36.1

# 检查是否传递了 ARCH 参数
if [ -z "$1" ]; then
  echo "Usage: $0 <ARCH>"
  echo "ARCH options: arm64, x86_64"
  exit 1
fi

ARCH=$1

# 根据 ARCH 设置交叉编译器和安装目录
if [ "$ARCH" = "arm64" ]; then
  CROSS_COMPILE="aarch64-linux-gnu-"
  INSTALL_DIR="$BUSYBOX/arm64_install"
elif [ "$ARCH" = "x86_64" ]; then
  CROSS_COMPILE=""
  INSTALL_DIR="$BUSYBOX/x86_install"
else
  echo "Unsupported ARCH: $ARCH"
  exit 1
fi

# 创建安装目录
# mkdir -p "$INSTALL_DIR"

# 进入 BusyBox 源代码目录
cd "$BUSYBOX" || exit 1

# 配置 BusyBox
make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" defconfig

# 生成安装配置
sed -i 's/.*CONFIG_STATIC.*/CONFIG_STATIC=y/' .config  # 静态编译，便于后续独立运行
make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" oldconfig

# 编译 BusyBox
make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" -j$(nproc)

# 安装 BusyBox 到指定目录
make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" CONFIG_PREFIX="$INSTALL_DIR" install

echo "BusyBox for $ARCH installed at $INSTALL_DIR"
