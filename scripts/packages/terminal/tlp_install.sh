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
    sudo zypper ref && sudo zypper dup -y && sudo zypper in -y tlp
elif command -v xbps-install &> /dev/null; then
    echo "Detected: xbps"
    # Installs package(s)
    sudo xbps-install -u -y && sudo xbps-install -y tlp
else
    echo "Unsupported package manager"
    read -p "Press enter to exit"
    exit 1
fi

# Checks for flatpak and flathub
if ! command -v flatpak &> /dev/null || ! flatpak remote-list | grep -q "flathub"; then
    # Runs script to install flatpak and set up flathub
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Installs package(s)
flatpak update -y && flatpak install flathub -y tlpui

# Checks for init system
if ps -p 1 -o comm= | grep -q "systemd"; then
    echo "Detected: systemd"
    # Enables tlp on the system
    sudo systemctl enable --now tlp.service
elif ps -p 1 -o comm= | grep -q "runit"; then
    echo "Detected: runit"
    # Enables tlp on the system
    sudo ln -s /etc/sv/tlp /var/service
else
    echo "Unsupported init system"
    read -p "Press enter to exit"
    exit 1
fi

# Prints a conclusive message
echo "TLP is now installed"
read -p "Press enter to exit"
