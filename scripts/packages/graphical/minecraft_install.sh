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

# Prints the detected operating system
echo "Detected (ID): $os"
echo "Detected (ID_LIKE): $os_like"

# Checks for package manager
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Installs package(s)
    wget -O "$HOME/Downloads/Minecraft.deb" "https://launcher.mojang.com/download/Minecraft.deb"
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y "$HOME/Downloads/Minecraft.deb"
    rm -v "$HOME/Downloads/Minecraft.deb"
elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    # Installs package(s)
    wget -O "$HOME/Downloads/Minecraft.tar.gz" "https://launcher.mojang.com/download/Minecraft.tar.gz"
    tar -xvf "$HOME/Downloads/Minecraft.tar.gz" -C "$HOME/Downloads/"
    rm -v "$HOME/Downloads/Minecraft.tar.gz"
elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    # Checks for AUR helper
    if command -v paru > /dev/null 2>&1; then
        echo "Detected: paru"
        # Installs package(s)
        paru -Syu minecraft-launcher
    elif command -v yay > /dev/null 2>&1; then
        echo "Detected: yay"
        # Installs package(s)
        yay -Syu minecraft-launcher
    else
        # Installs package(s)
        sudo pacman -Syu --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
        
        # Installs package(s)
        yay -Syu minecraft-launcher
    fi
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    wget -O "$HOME/Downloads/Minecraft.tar.gz" "https://launcher.mojang.com/download/Minecraft.tar.gz"
    tar -xvf "$HOME/Downloads/Minecraft.tar.gz" -C "$HOME/Downloads/"
    rm -v "$HOME/Downloads/Minecraft.tar.gz"
elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    # Installs package(s)
    wget -O "$HOME/Downloads/Minecraft.tar.gz" "https://launcher.mojang.com/download/Minecraft.tar.gz"
    tar -xvf "$HOME/Downloads/Minecraft.tar.gz" -C "$HOME/Downloads/"
    rm -v "$HOME/Downloads/Minecraft.tar.gz"
elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    # Installs package(s)
    wget -O "$HOME/Downloads/Minecraft.tar.gz" "https://launcher.mojang.com/download/Minecraft.tar.gz"
    tar -xvf "$HOME/Downloads/Minecraft.tar.gz" -C "$HOME/Downloads/"
    rm -v "$HOME/Downloads/Minecraft.tar.gz"
else
    echo "Unsupported package manager"
    # Installs package(s)
    wget -O "$HOME/Downloads/Minecraft.tar.gz" "https://launcher.mojang.com/download/Minecraft.tar.gz"
    tar -xvf "$HOME/Downloads/Minecraft.tar.gz" -C "$HOME/Downloads/"
    rm -v "$HOME/Downloads/Minecraft.tar.gz"
fi

# Prints a conclusive message
echo "Minecraft is now installed"

