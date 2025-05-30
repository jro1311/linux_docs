#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs AUR helper yay if it is not already installed
    if ! command -v yay > /dev/null 2>&1; then
        echo "yay is not installed. Installing yay..."
        sudo pacman -Syu --needed --noconfirm git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    else
        echo "yay is already installed"
    fi
    # Installs package(s)
    yay -S ungoogled-chromium-bin 
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Runs script to install flatpak
    chmod +x $HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    $HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y io.github.ungoogled_software.ungoogled_chromium
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Adds repo(s)
    sudo dnf copr enable -y wojnilowicz/ungoogled-chromium 
    
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y ungoogled-chromium
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Runs script to install flatpak
    chmod +x $HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    $HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
    
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y io.github.ungoogled_software.ungoogled_chromium
else
    echo "Unknown package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y io.github.ungoogled_software.ungoogled_chromium
fi

# Prints a conclusive message to end the script
echo "Ungoogled Chromium is now installed."
