#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Checks for paru
    if command -v paru > /dev/null 2>&1; then
        # Installs package(s)
        paru -Syu xcursor-dmz
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
        yay -Syu xcursor-dmz
    fi
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y dmz-cursor-theme
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    echo "Manual installation required"
    echo "Go to https://github.com/rhizoome/dmz-cursors/"
    read -p "Press continue to exit"
    exit 1
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper ref && sudo zypper dup -y && sudo zypper in -y dmz-icon-theme-cursors
else
    echo "Unknown package manager."
    echo "Manual installation required"
    echo "Go to https://github.com/rhizoome/dmz-cursors/"
    read -p "Press continue to exit"
    exit 1
fi

# Prints a conclusive message
echo "DMZ cursor is now installed"
read -p "Press continue to exit"
