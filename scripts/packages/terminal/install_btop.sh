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

# Check for Snap
snap_installed=0
if command -v snap >/dev/null 2>&1; then
    snap_installed=1
    echo "${green}Snap detected. ${reset}"
fi

# List of packages
packages=("btop")

# Checks package manager and installs package(s)
case "$primary_package_manager" in
    "apt")
        sudo apt-get install -y "${packages[@]}" rocm-smi
        ;;
    "dnf")
        sudo dnf install -y "${packages[@]}" rocm-smi
        ;;
    "eopkg")
        sudo eopkg install -y "${packages[@]}" rocm-smi
        ;;
    "pacman")
        sudo pacman -S --needed --noconfirm "${packages[@]}" rocm-smi-lib
        ;;
    "xbps")
        sudo xbps-install -Sy "${packages[@]}" ROCm-SMI
        ;;
    "zypper")
        sudo zypper in -y "${packages[@]}"
        ;;
    "rpm-ostree")
        sudo rpm-ostree install "${packages[@]}" rocm-smi
        ;;
    *)
        if [[ "$snap_installed" -eq 1 ]]; then
            sudo snap install "${packages[@]}"
        else
            echo "${red}Unsupported package manager. ${reset}"
            exit 1
        fi
esac

# Makes directory(s)
mkdir -pv "$HOME/.config/btop"
    
# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/btop.conf" "$HOME/.config/btop/"

# Prints a conclusive message
echo "${green}btop is now installed. ${reset}"

