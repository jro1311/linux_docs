#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs AUR helper yay if it is not already installed
    if ! command -v yay > /dev/null 2>&1; then
        echo "yay is not installed. Installing yay..."
        sudo pacman -Syu --needed --noconfirm git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    else
        echo "yay is already installed"
    fi
        
    # Installs package(s)
    yay -S xfce-theme-greybird
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y greybird-gtk-theme
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y greybird-dark-theme greybird-light-theme
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    echo "Manual installation required. Go to https://github.com/shimmerproject/Greybird"
    exit 1
else
    echo "Unknown package manager"
    echo "Manual installation required. Go to https://github.com/shimmerproject/Greybird"
    exit 1
fi

# Prints a conclusive message to end the script
echo "Greybird theme is now installed."
