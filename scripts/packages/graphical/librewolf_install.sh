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
        paru -Syu librewolf-bin
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
        yay -Syu librewolf-bin
    fi
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y extrepo

    # Enables LibreWolf external repository
    sudo extrepo enable librewolf

    # Installs librewolf
    sudo apt-get update && sudo apt-get install -y librewolf
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Adds repo(s)
    curl -fsSL https://repo.librewolf.net/librewolf.repo | pkexec tee /etc/yum.repos.d/librewolf.repo
    
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y librewolf
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y librewolf
else
    echo "Unknown package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y librewolf
fi

# Prints a conclusive message
echo "LibreWolf is now installed"
read -p "Press enter to exit"
