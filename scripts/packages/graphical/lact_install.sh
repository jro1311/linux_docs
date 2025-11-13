#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Define package managers
primary_package_manager="unknown"
secondary_package_manager="unknown"

primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)
secondary_package_managers=(nala paru yay)

for cmd in "${primary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        primary_package_manager="$cmd"
        break
    fi
done

for cmd in "${secondary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        secondary_package_manager="$cmd"
        break
    fi
done

if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    echo "${green}Primary Package Manager: $primary_package_manager ${reset}"
fi

if [ "$secondary_package_manager" != "unknown" ]; then
    echo "${green}Secondary Package Manager: $secondary_package_manager ${reset}"
fi

# Check for Flatpak
flatpak_installed=0
if command -v flatpak > /dev/null 2>&1; then
    flatpak_installed=1
    echo "${green}Flatpak detected. ${reset}"
fi

# Define init system
init_system="unknown"
init_names=(systemd runit sysvinit openrc-init)
pid1_comm=$(ps -p 1 -o comm=)

for init_name in "${init_names[@]}"; do
    if [ "$pid1_comm" = "$init_name" ]; then
        init_system="$init_name"
        break
    fi
done

if [ "$init_system" != "unknown" ]; then
    echo "${green}Init System: $init_system ${reset}"
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

# List of packages
packages=("lact")
flatpaks=("io.github.ilya_zlobintsev.LACT")

# Checks for package manager and installs package(s)
case "$primary_package_manager" in
    "dnf")
        sudo dnf copr enable -y ilyaz/LACT
        sudo dnf install -y "${packages[@]}"
        ;;
    "eopkg")
        sudo eopkg install -y "${packages[@]}"
        ;;
    "pacman")
        sudo pacman -S --needed --noconfirm "${packages[@]}"
        ;;
    "xbps")
        sudo xbps-install -Sy LACT
        ;;
    *)
        if [ "$flatpak_installed" -eq 1 ]; then
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            flatpak install flathub -y "${flatpaks[@]}"
        else
            echo "${red}Unsupported package manager. ${reset}"
            exit 1
        fi
        ;;
esac

# Checks for init system and enables LACT service
if [ "$init_system" = "systemd" ]; then
    sudo systemctl enable --now lactd

elif [ "$init_system" = "runit" ]; then
    sudo ln -s /etc/sv/lactd /var/service
    
else
    echo "{$red}Unsupported init system. ${reset}"
    exit 1
fi

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Kernel argument(s)
gpu_karg="amdgpu.ppfeaturemask=0xffffffff"

# Checks for AMD GPU
if echo "$gpu_info" | grep -Fiq "amd"; then
    echo "${green}Detected GPU: AMD ${reset}"

    # Checks for package manager or bootloader, then adds kernel argument(s)
    case "$primary_package_manager" in
        "rpm-ostree")
            if ! rpm-ostree kargs | grep -Fq "$gpu_karg"; then
                sudo rpm-ostree kargs --append="$gpu_karg"
                echo "${green}'$gpu_karg' added to kernel arguments. ${reset}"

            else
                echo "${green}'$gpu_karg' is already part of kernel arguments. ${reset}"
            fi
            ;;
        *)
            case "$bootloader" in
                "grub")
                    if ! grep -Fq "$gpu_karg" /etc/default/grub; then
                        sudo sed -i "s/\(GRUB_CMDLINE_LINUX=\"[^\"]*\)\"/\1 $gpu_karg\"/" /etc/default/grub
                        sudo bash -c "$update_bootloader"
                        echo "${green}'$gpu_karg' added to kernel arguments. ${reset}"

                    else
                        echo "${green}'$gpu_karg' is already part of kernel arguments. ${reset}"
                    fi
                    ;;
                "limine")
                    if ! grep -Fq "$gpu_karg" /etc/default/limine; then
                        sudo sed -i "/^KERNEL_CMDLINE\[default\\]/ s/\"$/ $gpu_karg\"/" /etc/default/limine
                        sudo bash -c "$update_bootloader"
                        echo "${green}'$gpu_karg' added to kernel arguments. ${reset}"

                    else
                        echo "${green}'$gpu_karg' is already part of kernel arguments. ${reset}"
                    fi
                    ;;
            esac
            ;;
    esac

else
    echo "${yellow}No AMD GPU detected. ${reset}"
fi

# Prints a conclusive message
echo "${green}LACT is now installed. ${reset}"

