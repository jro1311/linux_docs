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
    # Checks for paru
    if command -v paru > /dev/null 2>&1; then
        # Installs package(s)
        paru -Syu minecraft-launcher
    fi

    # Checks for yay
    if command -v yay > /dev/null 2>&1; then
        # Installs package(s)
        yay -Syu minecraft-launcher
    else
        sudo pacman -Syu --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
        
        # Installs package(s)
        yay -Syu minecraft-launcher
    fi
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    wget -O "$HOME/Downloads/Minecraft.deb" "https://launcher.mojang.com/download/Minecraft.deb"
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y "$HOME/Downloads/Minecraft.deb"
    rm -v "$HOME/Downloads/Minecraft.deb"
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    wget -O "$HOME/Downloads/Minecraft.tar.gz" "https://launcher.mojang.com/download/Minecraft.tar.gz"
    tar -xvf "$HOME/Downloads/Minecraft.tar.gz" -C "$HOME/Downloads/"
    rm -v "$HOME/Downloads/Minecraft.tar.gz"
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    wget -O "$HOME/Downloads/Minecraft.tar.gz" "https://launcher.mojang.com/download/Minecraft.tar.gz"
    tar -xvf "$HOME/Downloads/Minecraft.tar.gz" -C "$HOME/Downloads/"
    rm -v "$HOME/Downloads/Minecraft.tar.gz"
elif command -v xbps-install &> /dev/null; then
    echo "Detected: xbps"
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
read -p "Press enter to exit"
