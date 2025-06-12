#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for flatpak and flathub
if ! command -v flatpak &> /dev/null || ! flatpak remote-list | grep -q "flathub"; then
    # Runs script to install flatpak and set up flathub
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm discord
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    wget -O "$HOME/Downloads/discord.deb" "https://discord.com/api/download?platform=linux&format=deb"
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y "$HOME/Downloads/discord.deb"
    rm -v "$HOME/Downloads/discord.deb"
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y discord
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper ref && sudo zypper dup -y && sudo zypper in -y discord
else
    echo "Unknown package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y discordapp
fi

# Prints a conclusive message
echo "Discord is now installed"
read -p "Press enter to exit"
