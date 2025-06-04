#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs AUR helper yay if it is not already installed
    if ! command -v yay > /dev/null 2>&1; then
        echo "yay is not installed. Installing yay..."
        sudo pacman -Syu --needed --noconfirm git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    else
        echo "yay is already installed"
    fi
    # Installs package(s)
    yay -Syu librewolf-bin
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y extrepo

    # Enables LibreWolf external repository
    sudo extrepo enable librewolf

    # Installs librewolf
    sudo apt-get update && sudo apt-get install -y librewolf
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Adds repo(s)
    curl -fsSL https://repo.librewolf.net/librewolf.repo | pkexec tee /etc/yum.repos.d/librewolf.repo
    
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y librewolf
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Runs script to install flatpak
    chmod +x "$HOME"/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    "$HOME"/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y librewolf
else
    echo "Unknown package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y librewolf
fi

# Prints a conclusive message to end the script
echo "LibreWolf is now installed."
