#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
green=$(tput setaf 2)
reset=$(tput sgr0)

# Define primary package manager
primary_package_manager="unknown"
primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)

for cmd in "${primary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        primary_package_manager="$cmd"
        break
    fi
done

if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    echo "${green}Primary Package Manager: $primary_package_manager ${reset}"
fi

# Define bootloader
bootloader="unknown"
update_bootloader="unknown"

if command -v update-grub > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="update-grub"

elif command -v grub2-mkconfig > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub2-mkconfig -o /boot/grub2/grub.cfg"

elif command -v grub-mkconfig > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub-mkconfig -o /boot/grub/grub.cfg"

elif command -v limine-update > /dev/null 2>&1; then
    bootloader="limine"
    update_bootloader="limine-update"

elif find /boot/efi/EFI -name "*systemd-boot*.efi" > /dev/null 2>&1; then
    bootloader="systemd-boot"
    update_bootloader="bootctl update"
fi

if [ "$bootloader" != "unknown" ]; then
    echo "${green}Bootloader: $bootloader ${reset}"
fi

# Enables zswap on runtime
echo 1 | sudo tee /sys/module/zswap/parameters/enabled

# Kernel arguments
zswap_karg="zswap.enabled=1"

# Checks for package manager or bootloader, then adds kernel argument(s)
case "$primary_package_manager" in
    "rpm-ostree")
        if ! rpm-ostree kargs | grep -Fq "$zswap_karg"; then
            sudo rpm-ostree kargs --append=preempt=lazy
            echo "${green}'Added $zswap_karg' to kernel arguments. ${reset}"

        else
            echo "${green}'$zswap_karg' is already part of kernel arguments. ${reset}"
        fi
        ;;
    *)
        case "$bootloader" in
            "grub")
                if ! grep -Fq "$zswap_karg" /etc/default/grub; then
                    sudo sed -i "s/\(GRUB_CMDLINE_LINUX=\"[^\"]*\)\"/\1 $zswap_karg\"/" /etc/default/grub
                    echo "${green}Added '$zswap_karg' to kernel arguments. ${reset}"

                else
                    echo "${green}'$zswap_karg' is already part of kernel arguments. ${reset}"
                fi
                ;;
            "limine")
                if ! grep -Fq "$zswap_karg" /etc/default/limine; then
                    sudo sed -i "/^KERNEL_CMDLINE\[default\\]/ s/\"$/ $zswap_karg\"/" /etc/default/limine
                    echo "${green}Added '$zswap_karg' to kernel arguments. ${reset}"

                else
                    echo "${green}'$zswap_karg' is already part of kernel arguments. ${reset}"
                fi
                ;;
        esac
        ;;
esac

# Updates bootloader
if [ "$bootloader" = "grub" ]; then
    sudo bash -c "$update_bootloader"

elif [ "$bootloader" = "limine" ]; then
    sudo bash -c "$update_bootloader"
fi

# Prints a conclusive message
echo "${green}zswap is now enabled. ${reset}"
