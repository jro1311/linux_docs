#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs packages based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Runs script to install flatpak
    chmod +x $HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    $HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y spotify
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Sets up the Spotify repository on your system and adds its keyring for secure package verification
    curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

        # Installs package(s)
    sudo apt update && sudo apt upgrade -y && sudo apt install -y spotify-client
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Runs script to install flatpak
    chmod +x $HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    $HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y spotify
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Runs script to install flatpak
    chmod +x $HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    $HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y spotify
else
    echo "Unknown package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y spotify
fi

# Prints a conclusive message to end the script
echo "Spotify is now installed."
