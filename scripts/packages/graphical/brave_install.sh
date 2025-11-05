#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
green=$(tput setaf 2)
reset=$(tput sgr0)

# Installs Brave
curl -fsS https://dl.brave.com/install.sh | sh

# Checks for package
if ! command -v brave-browser > /dev/null 2>&1; then

    # Checks for flatpak and flathub
    if ! command -v flatpak > /dev/null 2>&1 || ! flatpak remote-list | grep -q "flathub"; then
        chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
        "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    fi

    flatpak install flathub -y com.brave.Browser
fi

# Prints a conclusive message
echo "${green}Brave is now installed. ${reset}"
