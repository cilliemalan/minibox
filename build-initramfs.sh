#!/bin/sh

# mkdir -p bin sbin etc proc sys usr/bin usr/sbin
cp -a initramfs/* build/initramfs
cp -a build/busybox/_install/* build/initramfs
cd build/initramfs
find . -print0 | cpio --null -o --format=newc | gzip -9 > ../initramfs.cpio.gz

