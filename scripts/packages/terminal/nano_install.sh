#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

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

# Detect AUR package manager
if command -v paru > /dev/null 2>&1; then
    aur_package_manager="paru"

elif command -v yay > /dev/null 2>&1; then
    aur_package_manager="yay"
    
else
    aur_package_manager="unknown"
fi

# List of packages
packages=("nano")
aur_packages=("nano-syntax-highlighting")

# Checks for main package manager and installs package(s)
if [ "$main_package_manager" = "apt" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo apt-get install -y "${packages[@]}"
    
elif [ "$main_package_manager" = "dnf" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo dnf install -y "${packages[@]}"
    
elif [ "$main_package_manager" = "pacman" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
    # Checks for AUR helper
    if [ "$aur_package_manager" != "unknown" ]; then
        echo "${green}Detected Package Manager: $aur_package_manager ${reset}"
        # Installs package(s)
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
    
elif [ "$main_package_manager" = "xbps" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo xbps-install -Sy "${packages[@]}"
    
elif [ "$main_package_manager" = "zypper" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo zypper in -y "${packages[@]}"
    
elif [ "$main_package_manager" = "rpm-ostree" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo rpm-ostree install "${packages[@]}"
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/nano"

# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/nanorc" "$HOME/.config/nano/"

# Prints a conclusive message
echo "${green}nano is now installed ${reset}"

