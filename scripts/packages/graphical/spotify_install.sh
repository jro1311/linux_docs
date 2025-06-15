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
    sudo pacman -Syu --needed --noconfirm spotify-launcher
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Sets up the Spotify repository on your system and adds its keyring for secure package verification
    curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y spotify-client
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y spotify
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y spotify
elif command -v xbps-install &> /dev/null; then
    echo "Detected: xbps"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y spotify
else
    echo "Unsupported package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y spotify
fi

# Prints a conclusive message
echo "Spotify is now installed"
read -p "Press enter to exit"
