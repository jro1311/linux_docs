#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Checks for paru
    if command -v paru > /dev/null 2>&1; then
        # Installs package(s)
        paru -Syu xfce-theme-greybird
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
        yay -Syu xfce-theme-greybird
    fi
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
    echo "Manual installation required"
    echo "Go to https://github.com/shimmerproject/Greybird/"
    read -p "Press enter to exit"
    exit 1
else
    echo "Unknown package manager."
    echo "Manual installation required"
    echo "Go to https://github.com/shimmerproject/Greybird/"
    read -p "Press enter to exit"
    exit 1
fi

# Prints a conclusive message
echo "Greybird theme is now installed"
read -p "Press enter to exit"
