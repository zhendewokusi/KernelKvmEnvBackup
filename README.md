仅用于个人学习os的环境备份：


```bash
libyaml:	wget https://github.com/yaml/libyaml/archive/refs/tags/0.2.5.tar.gz
dtc: 		git://git.kernel.org/pub/scm/utils/dtc/dtc.git
libfdt:		git://git.kernel.org/pub/scm/utils/dtc/dtc.git
kvmtool:	https://github.com/kvmtool/kvmtool.git
linux:		https://github.com/torvalds/linux.git
busybox:	官网压缩包
qemu-9.0.2:	官网压缩包
```

kvm环境配置：

交叉编译 arm64 架构的 libyaml：

```bash
wget https://github.com/yaml/libyaml/archive/refs/tags/0.2.5.tar.gz
tar xzf 0.2.5.tar.gz
cd libyaml-0.2.5
autoreconf -fiv
./configure --host=aarch64-linux-gnu --prefix=/path/to/arm64/lib
make
make install
```

交叉编译 arm64 架构的 dtc：

```bash
➜  dtc git:(v1.7.1) make CC=aarch64-linux-gnu-gcc \
     AR=aarch64-linux-gnu-ar \
     RANLIB=aarch64-linux-gnu-gcc-ranlib \
     CFLAGS="-I/path/to/arm64/lib/include" \
     LDFLAGS="-L/path/to/arm64/lib/lib -Wl,-rpath,/path/to/arm64/lib/lib" \
     LIBS="-lyaml"
```

arm64交叉工具链下载地址：https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads

编译Linux-v5.11
ARCH=arm64 CROSS_COMPILE=../toolchains/arm-gnu-toolchain-11.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu- make defconfig
ARCH=arm64 CROSS_COMPILE=../toolchains/arm-gnu-toolchain-11.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu- make all -j32

编译busybox-1.36.1:

1. CONFIG_STATIC=y CONFIG_TC=n
ARCH=arm64 CROSS_COMPILE=../toolchains/arm-gnu-toolchain-11.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu- make defconfig
menuconfig打开静态编译（setting->Build Options  Build static binary）
ARCH=arm64 CROSS_COMPILE=../toolchains/arm-gnu-toolchain-11.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu- make menuconfig
ARCH=arm64 CROSS_COMPILE=../toolchains/arm-gnu-toolchain-11.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu- make all -j32
ARCH=arm64 CROSS_COMPILE=../toolchains/arm-gnu-toolchain-11.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu- make install

注：
make install后会在busy-1.36.1目录下生成_install目录

制作根文件系统
1. 进入_install目录

2. 执行ls命令，显示如下：
$ ls
bin  linuxrc  sbin  usr

3. 执行命令：mkdir -p dev etc home lib mnt proc root sys tmp var

4. vim etc/inittab，写入：
::sysinit:/etc/init.d/rcS
::respawn:-/bin/sh
::askfirst:-/bin/sh
::cttlaltdel:/bin/umount -a -r

5. chmod 755 etc/inittab

6. mkdir -p etc/init.d/

7. vim etc/init.d/rcS，写入：
echo "----------mount all in fstab----------------"
/bin/mount -a #读取/etc/fstab，加载文件系统
mkdir -p /dev/pts
mount -t devpts devpts /dev/pts
echo /sbin/mdev > /proc/sys/kernel/hotplug
mdev -s
echo "****************Hello Linux******************"
echo "Kernel Version:linux-5.11"
echo "***********************************************"

8. chmod 755 etc/init.d/rcS

9. vim etc/fstab，写入：
#device mount-point type option dump fsck
proc  /proc proc  defaults 0 0
temps /tmp  rpoc  defaults 0 0
none  /tmp  ramfs defaults 0 0
sysfs /sys  sysfs defaults 0 0
mdev  /dev  ramfs defaults 0 0

10. cd dev
11. sudo mknod console c 5 1
12. sudo mknod null c 1 3
13. cd ..
14. find . | cpio -o -H newc > rootfs.cpio

运行Linux，从EL1启动Linux
qemu-system-aarch64 \
	-machine type=virt,gic-version=2 \
	-cpu cortex-a57 \
	-smp 1 \
	-m 4G \
	-nographic \
	-kernel linux-5.11/arch/arm64/boot/Image \
	-initrd busybox-1.36.1/_install/rootfs.cpio \
	-append "rdinit=/linuxrc console=ttyAMA0" \
	-device virtio-scsi-device

编译arm64架构dtc-v1.7.1
git clone git://git.kernel.org/pub/scm/utils/dtc/dtc.git
cd dtc
git checkout v1.7.1
make CC=../toolchains/arm-gnu-toolchain-11.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-gcc AR=../toolchains/arm-gnu-toolchain-11.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-ar RANLIB=../toolchains/arm-gnu-toolchain-11.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-ranlib

编译arm64架构kvmtool
git clone https://github.com/kvmtool/kvmtool.git
注：
1. 编译前注意再Makefile中添加-static编译选项
2. 把dtc中编译的libfdt目录拷贝到kvmtool目录下
ARCH=arm64 CROSS_COMPILE=../toolchains/arm-gnu-toolchain-11.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu- LIBFDT_DIR=libfdt make all -j32

cd busybox-1.36.1/_install/
若已经存在rootfs.cpio，即之前制作的根文件系统，把之前的根文件系统给lkvm启动的linux虚拟机用，
cp rootfs.cpio rootfs.kvm.cpio
然后重新制作一个跟文件系统给qemu启动的linux用
rm rootfs.cpio
把编译好的lkvm和linux的Image文件都放进跟文件系统里
cp kvmtool/lkvm busybox-1.36.1/_install/
cp linux-5.11/arch/arm64/boot/Image busybox-1.36.1/_install/
cd busybox-1.36.1/_install/
find . | cpio -o -H newc > rootfs.cpio

运行Linux，从EL2启动Linux
qemu-system-aarch64 \
	-machine type=virt,gic-version=2,virtualization=on \
	-cpu cortex-a57 \
	-smp 1 \
	-m 512M \
	-nographic \
	-kernel linux-5.11/arch/arm64/boot/Image  \
	-initrd busybox-1.36.1/_install/rootfs.cpio   \
	-append "rdinit=/linuxrc console=ttyAMA0"

启动后ls后，应该有lkvm，Image，和rootfs.kvm.cpio，然后执行：
./lkvm run -k Image -m 256 -i rootfs.kvm.cpio -p "rdinit=/linuxrc console=ttyAMA0" -c 1 --name guest-18
注：上述命令完整格式为，./lkvm run --kernel Image -i rootfs.kvm.cpio -append "rdinit=/linuxrc console=ttyAMA0"
再ls，里面应该没有lkvm和Image
