#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Checks for yay
    if ! command -v yay > /dev/null 2>&1; then
        sudo pacman -Syu --needed --noconfirm git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    fi
    
    # Installs package(s)
    yay -Syu visual-studio-code-bin
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    wget -O "$HOME/Downloads/vscode.deb" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y "$HOME/Downloads/vscode.deb"
    rm -v "$HOME/Downloads/vscode.deb"
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    wget -O "$HOME/Downloads/vscode.rpm" "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
    sudo dnf upgrade -y && sudo dnf install -y "$HOME/Downloads/vscode.rpm"
    rm -v "$HOME/Downloads/vscode.rpm"
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    wget -O "$HOME/Downloads/vscode.rpm" "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
    sudo zypper ref && sudo zypper -y dup && sudo zypper in -y "$HOME/Downloads/vscode.rpm"
    rm -v "$HOME/Downloads/vscode.rpm"
else
    echo "Unknown package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y app/com.visualstudio.code/x86_64/stable
fi

# Prints a conclusive message
echo "vscode is now installed"
read -p "Press enter to exit"
