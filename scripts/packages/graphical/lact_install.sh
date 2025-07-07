#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for flatpak and flathub
if ! command -v flatpak > /dev/null 2>&1 || ! flatpak remote-list | grep -q "flathub"; then
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Detect init
if ps -p 1 -o comm= | grep -q "systemd"; then
    init_system="systemd"
    
elif ps -p 1 -o comm= | grep -q "runit"; then
    init_system="runit"
    
else
    init_system="unknown"
fi

# Detect main package manager
if command -v apt > /dev/null 2>&1; then
    main_package_manager="apt"
     
elif command -v dnf > /dev/null 2>&1; then
    main_package_manager="dnf"
    
elif command -v pacman > /dev/null 2>&1; then
    main_package_manager="pacman"
    
elif command -v xbps-install > /dev/null 2>&1; then
    main_package_manager="xbps"
    
elif command -v zypper > /dev/null 2>&1; then
    main_package_manager="zypper"

elif command -v rpm-ostree > /dev/null 2>&1; then
    main_package_manager="rpm-ostree"

else
    main_package_manager="unknown"
fi

# Detect secondary package manager
if command -v flatpak > /dev/null 2>&1; then
    secondary_package_manager="flatpak"

else
    secondary_package_manager="unknown"
fi

# List of packages
packages=("lact")
flatpaks=("io.github.ilya_zlobintsev.LACT")

# Checks for main package manager
if [ "$main_package_manager" = "apt" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    flatpak install flathub -y "${flatpaks[@]}"

elif [ "$main_package_manager" = "dnf" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    # Adds repo(s)
    sudo dnf copr enable -y ilyaz/LACT
    sudo dnf install -y "${packages[@]}"

elif [ "$main_package_manager" = "pacman" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
elif [ "$main_package_manager" = "xbps" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo xbps-install -Sy LACT

elif [ "$main_package_manager" = "zypper" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    flatpak install flathub -y "${flatpaks[@]}"
    
elif [ "$secondary_package_manager" = "flatpak" ]; then
    echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
    flatpak install flathub -y "${flatpaks[@]}"
    
elif [ "$main_package_manager" = "rpm-ostree" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    flatpak install flathub -y "${flatpaks[@]}"
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Checks for init system and enables LACT service
if [ "$init_system" = "systemd" ]; then
    echo "${green}Detected Init System: $init_system ${reset}"
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

# Checks for file
if [ -f /etc/default/grub ]; then
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -iq "amd"; then
        echo "${green}Detected GPU: AMD ${reset}"
        # Adds kernel argument(s)
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
        
        # Updates GRUB configuration
        if command -v update-grub > /dev/null 2>&1; then
            echo "${green}Detected Bootloader: GRUB ${reset}"
            sudo update-grub
            
        elif command -v grub2-mkconfig > /dev/null 2>&1; then
            echo "${green}Detected Bootloader: GRUB ${reset}"
            sudo grub2-mkconfig -o /boot/grub2/grub.cfg
            
        elif command -v grub-mkconfig > /dev/null 2>&1; then
            echo "${green}Detected Bootloader: GRUB ${reset}"
            sudo grub-mkconfig -o /boot/grub/grub.cfg
        fi
        
    else
        echo "{$yellow}No AMD GPU detected {$reset}"
    fi
    
else
    echo "{$yellow}GRUB not detected {$reset}"
fi

# Prints a conclusive message
echo "${green}LACT is now installed ${reset}"

