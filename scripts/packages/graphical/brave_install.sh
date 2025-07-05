#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for flatpak and flathub
if ! command -v flatpak > /dev/null 2>&1 || ! flatpak remote-list | grep -q "flathub"; then
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Installs Brave
curl -fsS https://dl.brave.com/install.sh | sh

# Checks for package
if ! command -v brave-browser > /dev/null 2>&1; then
    flatpak install flathub -y brave
fi

# Prints a conclusive message
echo "Brave is now installed"
