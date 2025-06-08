#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm tlp
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y tlp
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y tlp
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper ref && sudo zypper -y dup && sudo zypper in -y tlp
else
    echo "Unknown package manager"
    exit 1
fi

# Runs script to install flatpak
chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
"$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"

# Installs package(s)
flatpak update -y && flatpak install flathub -y tlpui

# Enables tlp on the system
sudo systemctl enable --now tlp.service

# Prints a conclusive message to end the script
echo "TLP is now installed."
