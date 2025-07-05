#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for package manager
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    echo "Manual installation required"
    echo "Go to https://design.ubuntu.com/font/"
    exit 0
    
elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    echo "Manual installation required"
    echo "Go to https://design.ubuntu.com/font/"
    exit 0
    
elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    # Installs package(s)
    # Installs package(s)
    sudo pacman -S --needed --noconfirm ttf-ubuntu-font-family
    
elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    echo "Manual installation required"
    echo "Go to https://design.ubuntu.com/font/"
    exit 0
    
elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper in -y ubuntu-fonts
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    echo "Manual installation required"
    echo "Go to https://design.ubuntu.com/font/"
    exit 0
    
else
    echo "Unsupported package manager"
    exit 1
fi

# Prints a conclusive message
echo "Ubuntu fonts is now installed"

