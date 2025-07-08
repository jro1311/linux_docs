#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Define init system
if ps -p 1 -o comm= | grep -q "systemd"; then
    init_system="systemd"
    echo "${green}Detected Init System: $init_system ${reset}"
    
elif ps -p 1 -o comm= | grep -q "runit"; then
    init_system="runit"
    echo "${green}Detected Init System: $init_system ${reset}"
    
else
    init_system="unknown"
fi

# Define bootloader
if command -v update-grub > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="sudo update-grub"
    echo "${green}Detected Bootloader: $bootloader ${reset}"
    
elif command -v grub2-mkconfig > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
    echo "${green}Detected Bootloader: $bootloader ${reset}"
    
elif command -v grub-mkconfig > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="sudo grub-mkconfig -o /boot/grub/grub.cfg"
    echo "${green}Detected Bootloader: $bootloader ${reset}"
    
else
    bootloader="unknown"
    update_bootloader="unknown"
fi

# Define main package manager
if command -v apt > /dev/null 2>&1; then
    primary_package_manager="apt"
    echo "Detected Package Manager: $primary_package_manager"
    
elif command -v dnf > /dev/null 2>&1; then
    primary_package_manager="dnf"
    echo "Detected Package Manager: $primary_package_manager"
    
elif command -v pacman > /dev/null 2>&1; then
    primary_package_manager="pacman"
    echo "Detected Package Manager: $primary_package_manager"
    
elif command -v xbps-install > /dev/null 2>&1; then
    primary_package_manager="xbps"
    echo "Detected Package Manager: $primary_package_manager"
    
elif command -v zypper > /dev/null 2>&1; then
    primary_package_manager="zypper"
    echo "Detected Package Manager: $primary_package_manager"
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    primary_package_manager="rpm-ostree"
    echo "Detected Package Manager: $primary_package_manager"
    
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
    echo "Detected Package Manger: $secondary_package_manager"
    
else
    secondary_package_manager="unknown"
fi

# List of packages
packages=("lact")
flatpaks=("io.github.ilya_zlobintsev.LACT")

# Checks for package manager
if [ "$primary_package_manager" = "dnf" ]; then
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
    # Adds repo(s)
    sudo dnf copr enable -y ilyaz/LACT
    sudo dnf install -y "${packages[@]}"

elif [ "$primary_package_manager" = "pacman" ]; then
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
elif [ "$primary_package_manager" = "xbps" ]; then
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    sudo xbps-install -Sy LACT

elif [ "$secondary_package_manager" = "flatpak" ]; then
    echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
    flatpak install flathub -y "${flatpaks[@]}"
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Checks for init system and enables LACT service
if [ "$init_system" = "systemd" ]; then
    sudo systemctl enable --now lactd

elif [ "$init_system" = "runit" ]; then
    echo "${green}Detected Init System: $init_system ${reset}"
    sudo ln -s /etc/sv/lactd /var/service
    
else
    echo "{$red}Unsupported init system ${reset}"
    exit 1
fi

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for bootloader and AMD GPU, then adds kernel argument(s)
if [ "$bootloader" = "grub" ]; then
    if echo "$gpu_info" | grep -iq "amd"; then
        echo "${green}Detected GPU: AMD ${reset}"
        
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
        echo "${green}Added amdgpu.ppfeaturemask=0xffffffff to kernel arguments  ${reset}"
        
        "$update_bootloader"
    else
        echo "{$yellow}No AMD GPU detected {$reset}"
    fi
fi

# Prints a conclusive message
echo "${green}LACT is now installed ${reset}"

