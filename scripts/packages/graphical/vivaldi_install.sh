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
    # Runs script to install flatpak
    chmod +x ~/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    ~/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y vivaldi
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Runs script to install flatpak
    chmod +x ~/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    ~/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y vivaldi
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Runs script to install flatpak
    chmod +x ~/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    ~/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y vivaldi
else
    echo "Unknown package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y vivaldi
fi

# Prints a conclusive message to end the script
echo "Vivaldi is now installed."
