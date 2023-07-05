#!/bin/bash
set -e

# Dependency packages
sudo echo 'Installing packages...'
sudo apt update
sudo apt dist-upgrade -y
sudo apt install -y texinfo help2man libtool-bin libncurses5-dev unzip python3 build-essential libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf llvm bc
sudo apt autoremove -y

export ROOT=$(pwd)
export SRC=$ROOT/src
export BUILD=$ROOT/build
export LINUX=$SRC/linux
export BUSYBOX=$SRC/busybox
mkdir -p $SRC
export LINUX_BUILD=$BUILD/linux
export BUSYBOX_BUILD=$BUILD/busybox
export INITRAMFS_BUILD=$BUILD/initramfs
mkdir -p $LINUX_BUILD $BUSYBOX_BUILD $INITRAMFS_BUILD

echo 'Checking out Linux'
rm -rf $LINUX
git clone https://github.com/torvalds/linux.git --depth=1 -b 'v6.4' $LINUX
echo 'Checking out Busybox'
rm -rf $BUSYBOX
git clone https://github.com/mirror/busybox.git --depth=1 -b '1_36_0' $BUSYBOX

echo
echo
echo 'Building Linux'
cd $LINUX
make O=$LINUX_BUILD allnoconfig
cp $ROOT/linux.config $LINUX_BUILD/.config
cd $LINUX_BUILD
make -j$(nproc)
cp $LINUX_BUILD/arch/x86/boot/bzImage $BUILD/bzImage


echo
echo
echo 'Building Busybox'
cd $BUSYBOX
make O=$BUSYBOX_BUILD defconfig
cp $ROOT/busybox.config $BUSYBOX_BUILD/.config
cd $BUSYBOX_BUILD
make -j$(nproc)
make install


echo
echo
echo 'Building initramfs'
cd $INITRAMFS_BUILD
mkdir -p bin sbin etc proc sys usr/bin usr/sbin
cp -a $BUSYBOX_BUILD/_install/* .
cp $ROOT/init .
chmod +x init
find . -print0 | cpio --null -ov --format=newc | gzip -9 > $BUILD/initramfs.cpio.gz
 

