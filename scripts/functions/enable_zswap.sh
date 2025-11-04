#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
green=$(tput setaf 2)
reset=$(tput sgr0)

# Define primary package manager
if command -v apt > /dev/null 2>&1; then
    primary_package_manager="apt"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

elif command -v dnf > /dev/null 2>&1; then
    primary_package_manager="dnf"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

elif command -v pacman > /dev/null 2>&1; then
    primary_package_manager="pacman"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

elif command -v xbps-install > /dev/null 2>&1; then
    primary_package_manager="xbps"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

elif command -v zypper > /dev/null 2>&1; then
    primary_package_manager="zypper"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

elif command -v rpm-ostree > /dev/null 2>&1; then
    primary_package_manager="rpm-ostree"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

else
    primary_package_manager="unknown"
fi

# Define bootloader
if command -v update-grub > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="update-grub"
    echo "${green}Detected Bootloader: $bootloader ${reset}"

elif command -v grub2-mkconfig > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub2-mkconfig -o /boot/grub2/grub.cfg"
    echo "${green}Detected Bootloader: $bootloader ${reset}"

elif command -v grub-mkconfig > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub-mkconfig -o /boot/grub/grub.cfg"
    echo "${green}Detected Bootloader: $bootloader ${reset}"

elif command -v limine-update > /dev/null 2>&1; then
    bootloader="limine"
    update_bootloader="limine-update"
    echo "${green}Detected Bootloader: $bootloader ${reset}"

elif find /boot/efi/EFI -name "*systemd-boot*.efi" > /dev/null 2>&1; then
    bootloader="systemd-boot"
    update_bootloader="bootctl update"
    echo "${green}Detected Bootloader: $bootloader ${reset}"

else
    bootloader="unknown"
    update_bootloader="unknown"
fi

# Enables zswap on runtime
echo 1 | sudo tee /sys/module/zswap/parameters/enabled

# Checks for package manager or bootloader, then adds kernel argument(s)
if [ "$primary_package_manager" = "rpm-ostree" ]; then
    if ! rpm-ostree kargs | grep -Fq "zswap.enabled=1"; then

        sudo rpm-ostree kargs --append=zswap.enabled=1
        echo "${green}Added zswap.enabled=1 to kernel arguments. ${reset}"

    else
        echo "${green}zswap.enabled=1 already part of kernel arguments. ${reset}"
    fi

elif [ "$bootloader" = "grub" ]; then
    if ! grep -Fq "zswap.enabled=1" /etc/default/grub; then

        sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 zswap.enabled=1"/' /etc/default/grub
        echo "${green}Added zswap.enabled=1 to kernel arguments. ${reset}"

    else
        echo "${green}zswap.enabled=1 already part of kernel arguments. ${reset}"
    fi

elif [ "$bootloader" = "limine" ]; then
    if ! grep -Fq "zswap.enabled=1" /etc/default/limine; then

        sudo sed -i '/^KERNEL_CMDLINE\[default\]/ s/"$/ zswap.enabled=1"/' /etc/default/limine
        echo "${green}Added zswap.enabled=1 to kernel arguments. ${reset}"

    else
        echo "${green}zswap.enabled=1 already part of kernel arguments ${reset}"
    fi
fi

# Updates bootloader
if [ "$bootloader" = "grub" ]; then
    sudo bash -c "$update_bootloader"

elif [ "$bootloader" = "limine" ]; then
    sudo bash -c "$update_bootloader"
fi

# Prints a conclusive message
echo "${green}zswap is now enabled. ${reset}"
