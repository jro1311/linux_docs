#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Packages
packages=("redshift-gtk")

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
    sudo pacman -S --needed --noconfirm redshift
    
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

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"

# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"

# Adds package(s) to autostart
cp -v /usr/share/applications/redshift-gtk.desktop "$HOME/.config/autostart/"

# Prints a conclusive message
echo "Redshift is now installed"

