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
    sudo pacman -Syu --needed --noconfirm mpv
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y mpv
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y mpv
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper ref && sudo zypper dup -y && sudo zypper in -y mpv
elif command -v xbps-install &> /dev/null; then
    echo "Detected: xbps"
    # Installs package(s)
    sudo xbps-install -u -y && sudo xbps-install -y mpv
else
    echo "Unsupported package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y app/io.mpv.Mpv/x86_64/stable
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/mpv"
mkdir -pv "$HOME/.var/app/io.mpv.Mpv/config/mpv"

# Enables nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Detects batteries and stores in a variable
batteries=(/sys/class/power_supply/BAT*)

# Checks for battery
if (( ${#batteries[@]} )); then
    echo "Detected System: Laptop"
    # Copies config(s)
    cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv_laptop" "$HOME/.config/"
    cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv_laptop" "$HOME/.var/app/io.mpv.Mpv/config/"
    
    # Changes name(s)
    mv -v "$HOME/.config/mpv_laptop" "$HOME/.config/mpv"
    mv -v "$HOME/.var/app/io.mpv.Mpv/config/mpv_laptop" "$HOME/.var/app/io.mpv.Mpv/config/mpv"
    
else
    echo "Detected System: Desktop"
    # Copies config(s)
    cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.config/"
    cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"
fi

# Prints a conclusive message
echo "mpv is now installed"
read -p "Press enter to exit"
