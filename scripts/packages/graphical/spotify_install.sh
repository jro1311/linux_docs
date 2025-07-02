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

# Installs package(s) based on the package manager detected
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Sets up the Spotify repository on your system and adds its keyring for secure package verification
    curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y spotify-client
elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y spotify
elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm spotify-launcher
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y spotify
elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y spotify
elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
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
