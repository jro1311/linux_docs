#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Detects the operating system and stores it in a variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "Unable to detect the operating system"
    read -p "Press enter to exit"
    exit 1
fi

# Converts the variable into lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Prints the detected operating system
echo "Detected (ID): $os"
echo "Detected (ID_LIKE): $os_like"

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm ttf-ubuntu-font-family
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    echo "Manual installation required"
    echo "Go to https://design.ubuntu.com/font/"
    read -p "Press enter to exit"
    exit 1
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    echo "Manual installation required"
    echo "Go to https://design.ubuntu.com/font/"
    read -p "Press enter to exit"
    exit 1
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
        sudo zypper ref && sudo zypper dup -y && sudo zypper in -y ubuntu-fonts
    elif [ "$os" = "opensuse-leap" ]; then
        sudo zypper ref && sudo zypper up -y && sudo zypper in -y ubuntu-fonts
    else
        echo "Unsupported operating system"
        read -p "Press enter to exit"
        exit 1
    fi
elif command -v xbps-install &> /dev/null; then
    echo "Detected: xbps"
    echo "Manual installation required"
    echo "Go to https://design.ubuntu.com/font/"
    read -p "Press enter to exit"
    exit 1
else
    echo "Unsupported package manager"
    echo "Manual installation required"
    echo "Go to https://design.ubuntu.com/font/"
    read -p "Press enter to exit"
    exit 1
fi

# Prints a conclusive message
echo "Ubuntu fonts is now installed"
read -p "Press enter to exit"
