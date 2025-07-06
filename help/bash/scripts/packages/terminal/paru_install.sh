#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for package manager
if command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    # Checks for paru
    if ! command -v paru > /dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm git makepkg
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ..
        rm -rf paru
    else
        echo "paru is already installed"
        exit 1
    fi
else
    echo "Unsupported package manager"
    exit 1
fi

# Prints a conclusive message
echo "paru is now installed"

