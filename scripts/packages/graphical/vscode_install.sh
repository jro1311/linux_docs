#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Define package managers
primary_package_manager="unknown"
secondary_package_manager="unknown"

primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)
secondary_package_managers=(nala paru yay)

for cmd in "${primary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        primary_package_manager="$cmd"
        break
    fi
done

for cmd in "${secondary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        secondary_package_manager="$cmd"
        break
    fi
done

# Normalizes xbps-install to xbps
if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    echo "${green}Primary Package Manager: $primary_package_manager ${reset}"
fi

if [ "$secondary_package_manager" != "unknown" ]; then
    echo "${green}Secondary Package Manager: $secondary_package_manager ${reset}"
fi

# Check for Flatpak
flatpak_installed=0
if command -v flatpak >/dev/null 2>&1; then
    flatpak_installed=1
    echo "${green}Flatpak detected. ${reset}"
fi

# Check for Snap
snap_installed=0
if command -v snap >/dev/null 2>&1; then
    snap_installed=1
    echo "${green}Snap detected. ${reset}"
fi

# List of packages
aur_packages=("visual-studio-code-bin")
flatpaks=("com.visualstudio.code")
snaps=("code")

# Checks for package manager and installs package(s)
case "$primary_package_manager" in
    "apt")
        wget -O "$HOME/Downloads/vscode.deb" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
        sudo apt-get install -y "$HOME/Downloads/vscode.deb"
        rm -v "$HOME/Downloads/vscode.deb"
        ;;
    "dnf")
        wget -O "$HOME/Downloads/vscode.rpm" "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
        sudo dnf install -y "$HOME/Downloads/vscode.rpm"
        rm -v "$HOME/Downloads/vscode.rpm"
        ;;
    "pacman")
        if [[ "$secondary_package_manager" =~ ^(paru|yay)$ ]]; then
            "$secondary_package_manager" -S --needed --noconfirm "${aur_packages[@]}"
        else
            sudo pacman -S --needed --noconfirm base-devel git
            git clone https://aur.archlinux.org/paru.git
            cd paru
            makepkg -si --noconfirm
            cd ..
            rm -rf paru
            paru -S --needed --noconfirm "${aur_packages[@]}"
        fi
        ;;
    "xbps")
        sudo xbps-install -Sy vscode
        ;;
    "zypper")
        wget -O "$HOME/Downloads/vscode.rpm" "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
        sudo zypper in -y "$HOME/Downloads/vscode.rpm"
        rm -v "$HOME/Downloads/vscode.rpm"
        ;;
    *)
        if [[ "$flatpak_installed" -eq 1 ]]; then
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            flatpak install flathub -y "${flatpaks[@]}"

        elif [[ "$snap_installed" -eq 1 ]]; then
            sudo snap install "${snaps[@]}" --classic

        else
            echo "${red}Unsupported package manager. ${reset}"
            exit 1
        fi
        ;;
esac

# Prints a conclusive message
echo "${green}Visual Studio Code is now installed. ${reset}"

