#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Define init system
if ps -p 1 -o comm= | grep -Fq "systemd"; then
    init_system="systemd"
    echo "${green}Detected Init System: $init_system ${reset}"
    
elif ps -p 1 -o comm= | grep -Fq "runit"; then
    init_system="runit"
    echo "${green}Detected Init System: $init_system ${reset}"
    
else
    init_system="unknown"
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

# Define main package manager
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

# Checks for flatpak and flathub
if ! command -v flatpak > /dev/null 2>&1 || ! flatpak remote-list | grep -q "flathub"; then
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Define secondary package manager
if command -v flatpak > /dev/null 2>&1; then
    secondary_package_manager="flatpak"
    echo "${green}Detected Package Manger: $secondary_package_manager ${reset}"

else
    secondary_package_manager="unknown"
fi

# List of packages
packages=("lact")
flatpaks=("io.github.ilya_zlobintsev.LACT")

# Checks for package manager
if [ "$primary_package_manager" = "dnf" ]; then
    
    # Adds repo(s)
    sudo dnf copr enable -y ilyaz/LACT
    sudo dnf install -y "${packages[@]}"

elif [ "$primary_package_manager" = "pacman" ]; then
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
elif [ "$primary_package_manager" = "xbps" ]; then
    sudo xbps-install -Sy LACT

elif [ "$secondary_package_manager" = "flatpak" ]; then
    flatpak install flathub -y "${flatpaks[@]}"

else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Checks for init system and enables LACT service
if [ "$init_system" = "systemd" ]; then
    sudo systemctl enable --now lactd

elif [ "$init_system" = "runit" ]; then
    sudo ln -s /etc/sv/lactd /var/service
    
else
    echo "{$red}Unsupported init system ${reset}"
    exit 1
fi

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for AMD GPU
if echo "$gpu_info" | grep -Fiq "amd"; then
    echo "${green}Detected GPU: AMD$ ${reset}"
    
    # Checks for package manager or bootloader, then adds kernel argument(s)
    if [ "$primary_package_manager" = "rpm-ostree" ]; then
        if ! rpm-ostree kargs | grep -Fq "amdgpu.ppfeaturemask=0xffffffff"; then
        
            rpm-ostree kargs --append=amdgpu.ppfeaturemask=0xffffffff
            echo "${green}Added amdgpu.ppfeaturemask=0xffffffff to kernel arguments  ${reset}"
            
        else
            echo "${green}amdgpu.ppfeaturemask=0xffffffff already part of kernel arguments ${reset}"
        fi
        
    elif [ "$bootloader" = "grub" ]; then
        if ! grep -Fq "amdgpu.ppfeaturemask=0xffffffff" /etc/default/grub; then
        
            sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 amdgpu.ppfeaturemask=0xffffffff"/' /etc/default/grub
            echo "${green}Added amdgpu.ppfeaturemask=0xffffffff to kernel arguments  ${reset}"
            
        else
            echo "${green}amdgpu.ppfeaturemask=0xffffffff already part of kernel arguments ${reset}"
        fi
        
        sudo bash -c "$update_bootloader"
        
    elif [ "$bootloader" = "limine" ]; then
        if ! grep -Fq "amdgpu.ppfeaturemask=0xffffffff" /etc/default/limine; then
        
            sudo sed -i '/^KERNEL_CMDLINE\[default\]/ s/"$/ amdgpu.ppfeaturemask=0xffffffff"/' /etc/default/limine
            echo "${green}Added amdgpu.ppfeaturemask=0xffffffff to kernel arguments  ${reset}"
            
        else
            echo "${green}amdgpu.ppfeaturemask=0xffffffff already part of kernel arguments ${reset}"
        fi
        
        sudo bash -c "$update_bootloader"
        
    else
        echo "${red}Unable to add kernel argument(s) ${reset}"
    fi
    
else
    echo "${yellow}No AMD GPU detected ${reset}"
fi

# Prints a conclusive message
echo "${green}LACT is now installed. ${reset}"

