#!/bin/bash
set -e

# Dependency packages
sudo echo 'Installing packages...'
sudo apt update
sudo apt dist-upgrade -y
sudo apt install -y curl texinfo help2man libtool-bin libncurses5-dev unzip python3 build-essential libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf llvm bc
sudo apt autoremove -y

export ROOT=$(pwd)
export SRC=$ROOT/src
export BUILD=$ROOT/build
export LINUX="$SRC/linux-6.4"
export BUSYBOX="$SRC/busybox-1.36.1"
mkdir -p $SRC
export LINUX_BUILD=$BUILD/linux
export BUSYBOX_BUILD=$BUILD/busybox
export INITRAMFS_BUILD=$BUILD/initramfs
mkdir -p $LINUX_BUILD $BUSYBOX_BUILD $INITRAMFS_BUILD

if [ ! -f $LINUX_BUILD/.config ]
then
    echo 'Downloading Linux...'
    curl -s -L 'https://github.com/torvalds/linux/archive/refs/tags/v6.4.tar.gz' | tar xz -C $SRC
fi
if [ ! -f $BUSYBOX_BUILD/.config ]
then
    echo 'Downloading busybox...'
    curl -s -L 'https://www.busybox.net/downloads/busybox-1.36.1.tar.bz2' | tar xj -C $SRC
fi

echo
echo
echo 'Building Linux'
cd $LINUX
make O=$LINUX_BUILD alldefconfig
# to update ->  cp $LINUX_BUILD/.config $ROOT/linux.config
cp $ROOT/linux.config $LINUX_BUILD/.config
cd $LINUX_BUILD
make -j$(nproc)
cp $LINUX_BUILD/arch/x86/boot/bzImage $BUILD/bzImage


echo
echo
echo 'Building Busybox'
cd $BUSYBOX
make O=$BUSYBOX_BUILD defconfig
sed -i.bak 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' $BUSYBOX_BUILD/.config
cd $BUSYBOX_BUILD
make -j$(nproc)
make install


echo
echo
echo 'Building initramfs'
./build-initramfs.sh
 

