#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for flatpak and flathub
if ! command -v flatpak > /dev/null 2>&1 || ! flatpak remote-list | grep -q "flathub"; then
    # Runs script to install flatpak and set up flathub
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Packages
flatpaks=("vesktop")

# Checks for package manager
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y "${flatpaks[@]}"
    
elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y "${flatpaks[@]}"
    
elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    # Checks for Chaotic AUR
    if ! grep -q 'chaotic' /etc/pacman.conf; then
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
        sudo tee -a /etc/pacman.conf <<-'EOF'
        [chaotic-aur]
            Include = /etc/pacman.d/chaotic-mirrorlist

EOF
    fi
    
    # Checks for AUR helper
    if command -v paru > /dev/null 2>&1; then
        echo "Detected: paru"
        # Installs package(s)
        paru -S vesktop
    elif command -v yay > /dev/null 2>&1; then
        echo "Detected: yay"
        # Installs package(s)
        yay -S vesktop
    else
        # Installs package(s)
        sudo pacman -Syu --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ..
        rm -rf paru
        paru -S vesktop
    fi
    
elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y "${flatpaks[@]}"
    
elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y "${flatpaks[@]}"
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y "${flatpaks[@]}"
    
else
    echo "Unsupported package manager"
    exit 1
fi

# Prints a conclusive message
echo "${green}Vesktop is now installed ${reset}"
