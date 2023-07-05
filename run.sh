#!/bin/bash

qemu-system-x86_64 -kernel build/bzImage -initrd build/initramfs.cpio.gz -nographic -append 'console=ttyS0'

