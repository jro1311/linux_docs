#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Define bootloader
bootloader="unknown"
update_bootloader="unknown"

if command -v update-grub >/dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="update-grub"

elif command -v grub2-mkconfig >/dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub2-mkconfig -o /boot/grub2/grub.cfg"

elif command -v grub-mkconfig >/dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub-mkconfig -o /boot/grub/grub.cfg"

elif command -v limine-update >/dev/null 2>&1; then
    bootloader="limine"
    update_bootloader="limine-update"

elif find /boot/efi/EFI -name "*systemd-boot*.efi" >/dev/null 2>&1; then
    bootloader="systemd-boot"
    update_bootloader="bootctl update"
fi

if [ "$bootloader" != "unknown" ]; then
    echo "${green}Detected Bootloader:${reset} $bootloader"
fi

# Updates bootloader
case "$bootloader" in
    "grub")
        sudo bash -c "$update_bootloader"
        ;;
    "limine")
        sudo bash -c "$update_bootloader"
        ;;
    "systemd-boot")
        sudo bash -c "$update_bootloader"
        ;;
esac
