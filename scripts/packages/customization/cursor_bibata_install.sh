#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Detect the operating system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "Unable to detect the operating system"
    exit 1
fi

# Convert operating system to lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Packages
packages=("bibata-cursor-theme")

# Checks for package manager
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get install -y "${packages[@]}"

elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    if [ "$os" = "openmandriva" ]; then
        echo "Detected: OpenMandriva"
        echo "Manual installation required"
        echo "Go to https://github.com/ful1e5/Bibata_Cursor/"
        exit 0
    else 
        # Installs package(s)
        sudo dnf config-manager --add-repo https://terra.fyralabs.com/terra.repo
        sudo dnf install -y "${packages[@]}"
    fi
    
elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    echo "Manual installation required"
    echo "Go to https://github.com/ful1e5/Bibata_Cursor/"
    exit 0
    
elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    echo "Manual installation required"
    echo "Go to https://github.com/ful1e5/Bibata_Cursor/"
    exit 0
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    echo "Manual installation required"
    echo "Go to https://github.com/ful1e5/Bibata_Cursor/"
    exit 0
    
else
    echo "Unsupported package manager"
    exit 1
fi

# Prints a conclusive message
echo "Bibata Modern Ice cursor is now installed"

