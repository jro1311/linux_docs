#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Packages
aur_packages=("xcursor-dmz")

# Checks for package manager
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get install -y dmz-cursor-theme

elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    echo "Manual installation required"
    echo "Go to https://github.com/rhizoome/dmz-cursors/"
    exit 0
    
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
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ..
        rm -rf paru
        paru -S "${aur_packages[@]}"
    fi
    
elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    echo "Manual installation required"
    echo "Go to https://github.com/rhizoome/dmz-cursors/"
    exit 0
    
elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper in -y dmz-icon-theme-cursors
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    echo "Manual installation required"
    echo "Go to https://github.com/rhizoome/dmz-cursors/"
    exit 0

else
    echo "Unsupported package manager"
    exit 1
fi

# Prints a conclusive message
echo "DMZ cursor is now installed"
