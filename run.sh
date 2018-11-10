#!/bin/sh

exec qemu-system-x86_64 -enable-kvm --bios /usr/share/ovmf/x64/OVMF_CODE.fd -drive format=raw,file=sl2.gpt -serial stdio -net none -display none -m 4G -smp 4
