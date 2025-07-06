#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Packages
packages=("tlp")
flatpak_packages=("tlpui")

# Checks for package manager
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get install -y "${packages[@]}"

elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf install -y "${packages[@]}"

elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    # Installs package(s)
    sudo xbps-install -Sy "${packages[@]}"
    
elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper in -y "${packages[@]}"
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    sudo rpm-ostree install "${packages[@]}"

else
    echo "Unsupported package manager"
    exit 1
fi

# Checks for flatpak and flathub
if ! command -v flatpak > /dev/null 2>&1 || ! flatpak remote-list | grep -q "flathub"; then
    # Runs script to install flatpak and set up flathub
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Installs package(s)
flatpak install flathub -y "${flatpak_packages[@]}"

# Checks for init system
if ps -p 1 -o comm= | grep -q "systemd"; then
    echo "Detected: systemd"
    # Enables TLP service
    sudo systemctl enable --now tlp.service

elif ps -p 1 -o comm= | grep -q "runit"; then
    echo "Detected: runit"
    # Enables TLP service
    sudo ln -s /etc/sv/tlp /var/service

else
    echo "Unsupported init system"
    exit 1
fi

# Prints a conclusive message
echo "TLP is now installed"

