#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    wget -O "$HOME/Downloads/Minecraft.tar.gz" "https://launcher.mojang.com/download/Minecraft.tar.gz"
    tar -xvf "$HOME/Downloads/Minecraft.tar.gz" -C "$HOME/Downloads/"
    rm -v "$HOME/Downloads/Minecraft.tar.gz"
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
else
    echo "Unknown package manager."
    # Installs package(s)
    wget -O "$HOME/Downloads/Minecraft.tar.gz" "https://launcher.mojang.com/download/Minecraft.tar.gz"
    tar -xvf "$HOME/Downloads/Minecraft.tar.gz" -C "$HOME/Downloads/"
    rm -v "$HOME/Downloads/Minecraft.tar.gz"
fi

# Prints a conclusive message
echo "Minecraft is now installed."
