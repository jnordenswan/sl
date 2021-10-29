#!/bin/sh

#stty intr ^]
exec qemu-system-x86_64 --bios /usr/share/ovmf/x64/OVMF_CODE.fd -drive format=raw,file=sl2.gpt -serial mon:stdio -net none -nographic -m 4G -smp 4
