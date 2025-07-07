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
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Packages
aur_packages=("ungoogled-chromium-bin")
flatpaks=("io.github.ungoogled_software.ungoogled_chromium")

# Checks for package manager
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Installs package(s)
    flatpak install flathub -y "${flatpaks[@]}"
    
elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    # Enables COPR repo
    sudo dnf copr enable -y wojnilowicz/ungoogled-chromium 
    
    # Installs package(s)
    sudo dnf install -y ungoogled-chromium
    
elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    if command -v paru > /dev/null 2>&1; then
        echo "Detected: paru"
        # Installs package(s)
        paru -S "${aur_packages[@]}"
    elif command -v yay > /dev/null 2>&1; then
        echo "Detected: yay"
        # Installs package(s)
        yay -S "${aur_packages[@]}"
    else
        # Installs package(s)
        sudo pacman -S --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
        yay -S "${aur_packages[@]}"
    fi
    
elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    # Installs package(s)
    flatpak install flathub -y "${flatpaks[@]}"
    
elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    # Installs package(s)
    flatpak install flathub -y "${flatpaks[@]}"
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    flatpak install flathub -y "${flatpaks[@]}"
    
else
    echo "Unsupported package manager"
    exit 1
fi

# Prints a conclusive message
echo "${green}Ungoogled Chromium is now installed ${reset}"
