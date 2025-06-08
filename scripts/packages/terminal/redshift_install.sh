#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm redshift
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y redshift-gtk
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y redshift-gtk
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper ref && sudo zypper -y dup && sudo zypper in -y redshift-gtk
else
    echo "Unknown package manager."
    exit 1
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"

# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"

# Adds package(s) to autostart
cp -v /usr/share/applications/redshift-gtk.desktop "$HOME/.config/autostart/"

# Prints a conclusive message
echo "Redshift is now installed."
