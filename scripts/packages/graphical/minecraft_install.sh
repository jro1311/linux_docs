#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Define main package manager
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

# Define secondary package manager
if command -v flatpak > /dev/null 2>&1; then
    secondary_package_manager="flatpak"

elif command -v snap > /dev/null 2>&1; then
    secondary_package_manager="snap"

else
    secondary_package_manager="unknown"
fi

# Define AUR package manager
if command -v paru > /dev/null 2>&1; then
    aur_package_manager="paru"

elif command -v yay > /dev/null 2>&1; then
    aur_package_manager="yay"
    
else
    aur_package_manager="unknown"
fi

# Packages
aur_packages=("minecraft-launcher")

# Checks for package manager and installs package(s)
if [ "$main_package_manager" = "apt" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    wget -O "$HOME/Downloads/Minecraft.deb" "https://launcher.mojang.com/download/Minecraft.deb"
    sudo apt-get install -y "$HOME/Downloads/Minecraft.deb"
    rm -v "$HOME/Downloads/Minecraft.deb"

elif [ "$main_package_manager" = "pacman" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    # Checks for Chaotic AUR
    if ! grep -q 'chaotic' /etc/pacman.conf; then
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
        sudo tee -a /etc/pacman.conf <<-'EOF'
        [chaotic-aur]
            Include = /etc/pacman.d/chaotic-mirrorlist

EOF
        echo "${green}Added Chaotic AUR repository ${reset}"
    fi
    
    # Checks for AUR helper
    if [ "$aur_package_manager" ]; then
        echo "${green}Detected Package Manager: $aur_package_manager ${reset}"
        "$aur_package_manager" -S "${aur_packages[@]}"
    else
        # Installs package(s)
        sudo pacman -S --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ..
        rm -rf paru
        paru -S "${aur_packages[@]}"
    fi
else
    wget -O "$HOME/Downloads/Minecraft.tar.gz" "https://launcher.mojang.com/download/Minecraft.tar.gz"
    tar -xvf "$HOME/Downloads/Minecraft.tar.gz" -C "$HOME/Downloads/"
    rm -v "$HOME/Downloads/Minecraft.tar.gz"
fi

# Prints a conclusive message
echo "${green}Minecraft is now installed ${reset}"

