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
        exit 1
    fi
    
    # Installs package(s)
    yay -S snapd
    
    # Enables snapd
    sudo systemctl enable --now snapd.socket
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt update && sudo apt upgrade -y && sudo apt install -y snapd
    sudo snap install snapd
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y snapd
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Adds repo(s)
    sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
    
    # Imports GPG key
    sudo zypper --gpg-auto-import-keys refresh
    
    # Installs package(s)
    sudo zypper ref && sudo zypper dup -y && sudo zypper in -y snapd
    
    # Enables snapd
    sudo systemctl enable --now snapd
else
    echo "Unknown package manager"
    exit 1
fi

# Prints a conclusive message to end the script
echo "Snap is now installed."
