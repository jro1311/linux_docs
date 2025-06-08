#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs AUR helper yay if it is not already installed
    if ! command -v yay > /dev/null 2>&1; then
        sudo pacman -Syu --needed --noconfirm git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    fi
    
    # Installs package(s)
    yay -Syu zen-browser-bin
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Runs script to install flatpak
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y app/app.zen_browser.zen/x86_64/stable
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Runs script to install flatpak
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y app/app.zen_browser.zen/x86_64/stable
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Runs script to install flatpak
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y app/app.zen_browser.zen/x86_64/stable
else
    echo "Unknown package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y app/app.zen_browser.zen/x86_64/stable
fi

# Prints a conclusive message to end the script
echo "Zen is now installed."
