#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define bootloader
bootloader=""
update_bootloader_cmd=""
update_bootloader_args=""

if command -v update-grub >/dev/null 2>&1 ||
    command -v /usr/sbin/update-grub >/dev/null 2>&1; then
    bootloader="grub"
    update_bootloader_cmd="update-grub"

elif command -v grub2-mkconfig >/dev/null 2>&1; then
    bootloader="grub"
    update_bootloader_cmd="grub2-mkconfig"
    update_bootloader_args="-o /boot/grub2/grub.cfg"

elif command -v grub-mkconfig >/dev/null 2>&1; then
    bootloader="grub"
    update_bootloader_cmd="grub-mkconfig"
    update_bootloader_args="-o /boot/grub/grub.cfg"

elif command -v limine-update >/dev/null 2>&1; then
    bootloader="limine"
    update_bootloader_cmd="limine-update"

elif find /boot/efi/EFI -name "*systemd-boot*.efi" >/dev/null 2>&1; then
    bootloader="systemd-boot"
    update_bootloader_cmd="bootctl"
    update_bootloader_args="update"
fi

[ -n "$bootloader" ] && echo "${green}Bootloader:${reset} $bootloader"

# shellcheck disable=SC2086
if [ -n "$update_bootloader_args" ]; then
    sudo "$update_bootloader_cmd" $update_bootloader_args
else
    sudo "$update_bootloader_cmd"
fi
