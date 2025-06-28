#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Detects the operating system and stores it in a variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "Unable to detect the operating system"
    read -p "Press enter to exit"
    exit 1
fi

# Converts the variable into lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Prints the detected operating system
echo "Detected (ID): $os"
echo "Detected (ID_LIKE): $os_like"

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
        paru -Syu visual-studio-code-bin
    fi

    # Checks for yay
    if command -v yay > /dev/null 2>&1; then
        # Installs package(s)
        yay -Syu visual-studio-code-bin
    else
        # Installs yay
        sudo pacman -Syu --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
        
        # Installs package(s)
        yay -Syu visual-studio-code-bin
    fi
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
    if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
        wget -O "$HOME/Downloads/vscode.rpm" "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
        sudo zypper ref && sudo zypper dup -y && sudo zypper in -y "$HOME/Downloads/vscode.rpm"
        rm -v "$HOME/Downloads/vscode.rpm"
    elif [ "$os" = "opensuse-leap" ]; then
        wget -O "$HOME/Downloads/vscode.rpm" "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
        sudo zypper ref && sudo zypper up -y && sudo zypper in -y "$HOME/Downloads/vscode.rpm"
        rm -v "$HOME/Downloads/vscode.rpm"
    else
        echo "Unsupported operating system"
        read -p "Press enter to exit"
        exit 1
    fi
elif command -v xbps-install &> /dev/null; then
    echo "Detected: xbps"
    # Installs package(s)
    sudo xbps-install -Su xbps && sudo xbps-install -u && sudo xbps-install -y vscode
else
    echo "Unsupported package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y app/com.visualstudio.code/x86_64/stable
fi

# Prints a conclusive message
echo "VS Code is now installed"
read -p "Press enter to exit"
