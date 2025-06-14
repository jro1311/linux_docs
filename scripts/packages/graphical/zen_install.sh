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
    # Checks for paru
    if command -v paru > /dev/null 2>&1; then
        # Installs package(s)
        paru -Syu zen-browser-bin
    fi

    # Checks for yay
    if ! command -v yay > /dev/null 2>&1; then
        sudo pacman -Syu --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    else
        # Installs package(s)
        yay -Syu zen-browser-bin
    fi
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y app/app.zen_browser.zen/x86_64/stable
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y app/app.zen_browser.zen/x86_64/stable
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y app/app.zen_browser.zen/x86_64/stable
elif command -v xbps-install &> /dev/null; then
    echo "Detected: xbps"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y app/app.zen_browser.zen/x86_64/stable
else
    echo "Unsupported package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y app/app.zen_browser.zen/x86_64/stable
fi

# Prints a conclusive message
echo "Zen is now installed"
read -p "Press enter to exit"
