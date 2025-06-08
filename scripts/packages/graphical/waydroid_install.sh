#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs AUR helper yay if it is not already installed
    if ! command -v yay > /dev/null 2>&1; then
        sudo pacman -Syu --needed --noconfirm git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    fi
        
    # Installs package(s)
    yay -Syu waydroid
        
    # Initializes container
    sudo waydroid init
        
    # Enables container
    sudo systemctl enable --now waydroid-container
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y curl ca-certificates
        
    # Adds repo(s)
    curl -s https://repo.waydro.id | sudo bash
        
    # Installs package(s)
    sudo apt-get install -y waydroid
        
    # Enables container
    sudo systemctl enable --now waydroid-container
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y waydroid
        
    # Enables container
    sudo systemctl enable --now waydroid-container
        
    # Prints setup information
    echo "System OTA: https://ota.waydro.id/system"
    echo "Vendor OTA: https://ota.waydro.id/vendor"
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    echo "Manual installation required."
    exit 1
else
    echo "Unknown package manager."
    exit 1
fi

# Prints a conclusive message
echo "Waydroid is now installed."
