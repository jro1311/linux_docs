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
    sudo pacman -Syu --needed --noconfirm vivaldi
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y vivaldi
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y vivaldi
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y vivaldi
elif command -v xbps-install &> /dev/null; then
    echo "Detected: xbps"
    # Installs package(s)
    sudo xbps-install -Su xbps && sudo xbps-install -u && sudo xbps-install -y vivaldi
else
    echo "Unsupported package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y vivaldi
fi

# Prints a conclusive message
echo "Vivaldi is now installed"
read -p "Press enter to exit"
