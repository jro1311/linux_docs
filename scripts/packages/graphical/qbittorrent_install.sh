#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Detects the operating system and stores it in a variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "Unable to detect the operating system"
    read -p "Press enter to exit"
    exit 1
fi

# Converts the variable into lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Prints the detected operating system
echo "Detected (ID): $os"
echo "Detected (ID_LIKE): $os_like"

# Checks for flatpak and flathub
if ! command -v flatpak > /dev/null 2>&1 || ! flatpak remote-list | grep -q "flathub"; then
    # Runs script to install flatpak and set up flathub
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"

# Installs package(s) based on the package manager detected
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y qbittorrent
elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y qbittorrent
elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm qbittorrent
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y qbittorrent
    
    # Adds package(s) to autostart
    cp -v /var/lib/flatpak/exports/share/applications/org.qbittorrent.qBittorrent.desktop "$HOME/.config/autostart/"
    
    # Prints a conclusive message
    echo "qBittorrent is now installed"
    read -p "Press enter to exit"
    exit 0
elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    # Installs package(s)
    sudo xbps-install -Suy xbps && sudo xbps-install -uy && sudo xbps-install -y qbittorrent
elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    # Installs package(s)
    if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
        sudo zypper ref && sudo zypper dup -y && sudo zypper in -y qbittorrent
    elif [ "$os" = "opensuse-leap" ]; then
        sudo zypper ref && sudo zypper up -y && sudo zypper in -y qbittorrent
    else
        echo "Unsupported operating system"
        read -p "Press enter to exit"
        exit 1
    fi
else
    echo "Unsupported package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y qbittorrent
    
    # Adds package(s) to autostart
    cp -v /var/lib/flatpak/exports/share/applications/org.qbittorrent.qBittorrent.desktop "$HOME/.config/autostart/"
    
    # Prints a conclusive message
    echo "qBittorrent is now installed"
    read -p "Press enter to exit"
    exit 1
fi

# Adds package(s) to autostart
cp -v /usr/share/applications/org.qbittorrent.qBittorrent.desktop "$HOME/.config/autostart/"

# Prints a conclusive message
echo "qBittorrent is now installed"
read -p "Press enter to exit"

