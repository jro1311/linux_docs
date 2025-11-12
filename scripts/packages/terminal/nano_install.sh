#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
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

if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    echo "${green}Primary Package Manager: $primary_package_manager ${reset}"
fi

if [ "$secondary_package_manager" != "unknown" ]; then
    echo "${green}Secondary Package Manager: $secondary_package_manager ${reset}"
fi

# List of packages
packages=("nano")
aur_packages=("nano-syntax-highlighting")

# Checks for package manager and installs package(s)
case "$primary_package_manager" in
    "apt")
        sudo apt-get install -y "${packages[@]}"
        ;;
    "dnf")
        sudo dnf install -y "${packages[@]}"
        ;;
    "eopkg")
        sudo eopkg install -y "${packages[@]}"
        ;;
    "pacman")
        sudo pacman -S --needed --noconfirm "${packages[@]}"

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
        sudo xbps-install -Sy "${packages[@]}"
        ;;
    "zypper")
        sudo zypper in -y "${packages[@]}"
        ;;
    "rpm-ostree")
        sudo rpm-ostree install "${packages[@]}"
        ;;
    *)
        echo "${red}Unsupported package manager. ${reset}"
        exit 1
        ;;
esac

# Makes directory(s)
mkdir -pv "$HOME/.config/nano"

# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/nanorc" "$HOME/.config/nano/"
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/nanorc" /etc/nanorc

# Prints a conclusive message
echo "${green}nano is now installed. ${reset}"

