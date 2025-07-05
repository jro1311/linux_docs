#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for flatpak and flathub
if ! command -v flatpak > /dev/null 2>&1 || ! flatpak remote-list | grep -q "flathub"; then
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Packages
aur_packages=("visual-studio-code-bin")
flatpaks=("com.visualstudio.code")

# Checks for package manager
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Installs package(s)
    wget -O "$HOME/Downloads/vscode.deb" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    sudo apt-get install -y "$HOME/Downloads/vscode.deb"
    rm -v "$HOME/Downloads/vscode.deb"
    
elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    # Installs package(s)
    wget -O "$HOME/Downloads/vscode.rpm" "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
    sudo dnf install -y "$HOME/Downloads/vscode.rpm"
    rm -v "$HOME/Downloads/vscode.rpm"
    
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
    sudo xbps-install -Sy vscode
    
elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    # Installs package(s)
    wget -O "$HOME/Downloads/vscode.rpm" "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
    sudo zypper in -y "$HOME/Downloads/vscode.rpm"
    rm -v "$HOME/Downloads/vscode.rpm"
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    flatpak install flathub -y "${flatpaks[@]}"
    
else
    echo "Unsupported package manager"
    exit 1
fi

# Prints a conclusive message
echo "VS Code is now installed"

