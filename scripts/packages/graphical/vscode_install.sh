#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Define primary package manager
if command -v apt > /dev/null 2>&1; then
    primary_package_manager="apt"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v dnf > /dev/null 2>&1; then
    primary_package_manager="dnf"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v pacman > /dev/null 2>&1; then
    primary_package_manager="pacman"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v xbps-install > /dev/null 2>&1; then
    primary_package_manager="xbps"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v zypper > /dev/null 2>&1; then
    primary_package_manager="zypper"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    primary_package_manager="rpm-ostree"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
else
    primary_package_manager="unknown"
fi

# Checks for flatpak and flathub
if ! command -v flatpak > /dev/null 2>&1 || ! flatpak remote-list | grep -q "flathub"; then
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Define secondary package manager
if command -v flatpak > /dev/null 2>&1; then
    secondary_package_manager="flatpak"
    echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
    
elif command -v snap > /dev/null 2>&1; then
    secondary_package_manager="snap"
    echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
    
else
    secondary_package_manager="unknown"
fi

# Define AUR package manager
if command -v paru > /dev/null 2>&1; then
    aur_package_manager="paru"
    echo "Detected Package Manger: $aur_package_manager"

elif command -v yay > /dev/null 2>&1; then
    aur_package_manager="yay"
    echo "Detected Package Manger: $aur_package_manager"
    
else
    aur_package_manager="unknown"
fi

# List of packages
aur_packages=("visual-studio-code-bin")
flatpaks=("com.visualstudio.code")
snaps=("code")

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then
    wget -O "$HOME/Downloads/vscode.deb" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    sudo apt-get install -y "$HOME/Downloads/vscode.deb"
    rm -v "$HOME/Downloads/vscode.deb"

elif [ "$primary_package_manager" = "dnf" ]; then
    wget -O "$HOME/Downloads/vscode.rpm" "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
    sudo dnf install -y "$HOME/Downloads/vscode.rpm"
    rm -v "$HOME/Downloads/vscode.rpm"

elif [ "$primary_package_manager" = "pacman" ]; then

    # Checks for AUR package manager
    if [ "$aur_package_manager" != "unknown" ]; then
        "$aur_package_manager" -S "${aur_packages[@]}"
    else
        sudo pacman -S --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ..
        rm -rf paru
        paru -S "${aur_packages[@]}"
    fi
    
elif [ "$primary_package_manager" = "xbps" ]; then
    sudo xbps-install -Sy vscode

elif [ "$primary_package_manager" = "zypper" ]; then
    wget -O "$HOME/Downloads/vscode.rpm" "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
    sudo zypper in -y "$HOME/Downloads/vscode.rpm"
    rm -v "$HOME/Downloads/vscode.rpm"
    
elif [ "$secondary_package_manager" = "flatpak" ]; then
    flatpak install flathub -y "${flatpaks[@]}"
    
elif [ "$secondary_package_manager" = "snap" ]; then
    sudo snap install "${snaps[@]}" --classic
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Prints a conclusive message
echo "${green}Visual Studio Code is now installed. ${reset}"

