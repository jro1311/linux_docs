#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
if command -v tput &>/dev/null; then
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    yellow=$(tput setaf 3)
    blue=$(tput setaf 4)
    reset=$(tput sgr0)
else
    # Fallback for systems without tput
    red=$'\033[31m'
    green=$'\033[32m'
    yellow=$'\033[33m'
    blue=$'\033[34m'
    reset=$'\033[0m'
fi

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

# Normalize xbps-install to xbps
if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    echo "${green}Primary Package Manager:${reset} $primary_package_manager"
fi

if [ "$secondary_package_manager" != "unknown" ]; then
    echo "${green}Secondary Package Manager:${reset} $secondary_package_manager"
fi

# Defines toolbox package managers
toolbox_installed=0
primary_toolbox_manager="unknown"
secondary_toolbox_manager="unknown"

primary_toolbox_managers=(apt dnf eopkg pacman xbps-install zypper)
secondary_toolbox_managers=(nala paru yay)

if command -v toolbox >/dev/null 2>&1; then
    toolbox_installed=1
    for cmd in "${primary_toolbox_managers[@]}"; do
        if toolbox run bash -c "command -v $cmd >/dev/null 2>&1"; then
            primary_toolbox_manager="$cmd"
            break
        fi
    done

    for cmd in "${secondary_toolbox_managers[@]}"; do
        if toolbox run bash -c "command -v $cmd >/dev/null 2>&1"; then
            secondary_toolbox_manager="$cmd"
            break
        fi
    done
fi

# Normalizes xbps-install to xbps
if [ "$primary_toolbox_manager" = "xbps-install" ]; then
    primary_toolbox_manager="xbps"
fi

if [ "$primary_toolbox_manager" != "unknown" ]; then
    echo "${green}Primary Toolbox Manager:${reset} $primary_toolbox_manager"
fi

if [ "$secondary_toolbox_manager" != "unknown" ]; then
    echo "${green}Secondary Toolbox Manager:${reset} $secondary_toolbox_manager"
fi

# Check for Flatpak
flatpak_installed=0
if command -v flatpak >/dev/null 2>&1; then
    flatpak_installed=1
    echo "${green}Detected:${reset} flatpak"
fi

# Check for Snap
snap_installed=0
if command -v snap >/dev/null 2>&1; then
    snap_installed=1
    echo "${green}Detected:${reset} snap"
fi

# Check for Toolbox
toolbox_installed=0
if command -v toolbox >/dev/null 2>&1; then
    toolbox_installed=1
    echo "${green}Detected:${reset} toolbox"
fi

# List of packages
packages=(
    "package1"
    "package2"
)

aur_packages=(
    "package1"
    "package2"
)

flatpaks=(
    "flatpak1"
    "flatpak2"
)

snaps=(
    "snap1"
    "snap2"
)

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
        case "$secondary_package_manager" in
           "paru"|"yay")
            "$secondary_package_manager" -S --needed --noconfirm "${aur_packages[@]}"
            ;;
        *)
            pacman -S --needed --noconfirm "${packages[@]}"
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
        if [ "$flatpak_installed" -eq 1 ]; then
            echo "$installing"
            flatpak install flathub -y "${flatpaks[@]}"

        elif [ "$snap_installed" -eq 1 ]; then
            sudo snap install "${snaps[@]}"

        else
            echo "${red}Unsupported package manager.${reset}"
            exit 1
        fi
        ;;
esac
