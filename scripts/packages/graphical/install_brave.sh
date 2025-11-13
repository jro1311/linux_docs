#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Check for Flatpak
flatpak_installed=0
if command -v flatpak >/dev/null 2>&1; then
    flatpak_installed=1
    echo "${green}Flatpak detected. ${reset}"
fi

# Check for Snap
snap_installed=0
if command -v snap >/dev/null 2>&1; then
    snap_installed=1
    echo "${green}Snap detected. ${reset}"
fi

# Installs Brave
curl -fsS https://dl.brave.com/install.sh | sh

# Checks for package
if ! command -v brave-browser >/dev/null 2>&1; then

    if [ "$flatpak_installed" -eq 1 ]; then
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        flatpak install flathub -y com.brave.Browser

    elif [ "$snap_installed" -eq 1 ]; then
        sudo snap install brave

    else
        echo "${red}Unsupported package manager. ${reset}"
        exit 1
    fi

fi

# Prints a conclusive message
echo "${green}Brave is now installed. ${reset}"
