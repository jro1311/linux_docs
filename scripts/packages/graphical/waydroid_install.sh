#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Packages
packages=("waydroid")
aur_packages=("waydroid")

# Checks for package manager
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get install -y curl ca-certificates
    
    # Adds repo(s)
    curl -s https://repo.waydro.id | sudo bash
    
    # Installs package(s)
    sudo apt-get install -y "${packages[@]}"
    
    # Enables Waydroid container
    sudo systemctl enable --now waydroid-container

elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf install -y "${packages[@]}"
    
    # Enables Waydroid container
    sudo systemctl enable --now waydroid-container
    
    # Prints information required for Waydroid setup
    echo "System OTA: https://ota.waydro.id/system"
    echo "Vendor OTA: https://ota.waydro.id/vendor"

elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    if command -v paru > /dev/null 2>&1; then
        echo "Detected: paru"
        # Installs package(s)
        paru -S "${aur_packages[@]}"
    elif command -v yay > /dev/null 2>&1; then
        echo "Detected: yay"
        # Installs package(s)
        yay -S "${aur_packages[@]}"
    else
        # Installs package(s)
        sudo pacman -S --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
        yay -S "${aur_packages[@]}"
    fi
    
    # Initializes Waydroid
    sudo waydroid init
    
    # Enables Waydroid container
    sudo systemctl enable --now waydroid-container
    
elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    # Installs package(s)
    sudo xbps-install -Sy "${packages[@]}" python3-pyclip wl-clipboard
    
    # Initializes Waydroid
    sudo waydroid init
    
    # Enables Waydroid container
    sudo ln -s /etc/sv/waydroid-container /var/service
    
elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    echo "Manual installation required"
    exit 0
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    sudo rpm-ostree install "${packages[@]}"
    
else
    echo "Unsupported package manager"
    exit 1
fi

# Prints a conclusive message
echo "${green}Waydroid is now installed ${reset}"

