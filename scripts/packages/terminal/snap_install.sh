#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Checks for paru
    if command -v paru > /dev/null 2>&1; then
        # Installs package(s)
        paru -Syu snapd
    fi

    # Checks for yay
    if ! command -v yay > /dev/null 2>&1; then
        sudo pacman -Syu --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    else
        # Installs package(s)
        yay -Syu snapd
    fi
    
    # Enables snapd
    sudo systemctl enable --now snapd.socket
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y snapd
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
    read -p "Press enter to exit"
    exit 1
fi

# Prints a conclusive message
echo "Snap is now installed"
read -p "Press enter to exit"
