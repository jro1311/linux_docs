#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm vivaldi
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    wget -O $HOME/Downloads/vivaldi.deb "https://downloads.vivaldi.com/stable/vivaldi-stable_7.3.3635.11-1_amd64.deb"
    sudo apt update && sudo apt upgrade -y && sudo apt install -y $HOME/Downloads/vivaldi.deb
    rm -v $HOME/Downloads/vivaldi.deb
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    wget -O $HOME/Downloads/vivaldi.deb "https://downloads.vivaldi.com/stable/vivaldi-stable-7.3.3635.11-1.x86_64.rpm"
    sudo dnf upgrade -y && sudo dnf install -y $HOME/Downloads/vivaldi.rpm
    rm -v $HOME/Downloads/vivaldi.rpm
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Runs script to install flatpak
    chmod +x $HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    $HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y vivaldi
else
    echo "Unknown package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y vivaldi
fi

# Prints a conclusive message to end the script
echo "Vivaldi is now installed."
