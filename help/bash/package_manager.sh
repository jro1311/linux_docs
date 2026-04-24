#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define package managers
primary_pm=""
secondary_pm=""

primary_pms=(
    apt
    dnf
    eopkg
    pacman
    xbps-install
    zypper
    rpm-ostree
)

secondary_pms=(
    nala
    paru
    yay
)

for cmd in "${primary_pms[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        primary_pm="$cmd"
        break
    fi
done

for cmd in "${secondary_pms[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        secondary_pm="$cmd"
        break
    fi
done

# Normalize xbps-install to xbps
case "$primary_pm" in
    "xbps-install")
        primary_pm="xbps"
        ;;
esac

if [ -n "$primary_pm" ]; then
    echo "${green}Primary Package Manager:${reset} $primary_pm"
fi

if [ -n "$secondary_pm" ]; then
    echo "${green}Secondary Package Manager:${reset} $secondary_pm"
fi

# Defines toolbox package managers
toolbox_installed=0
primary_tbm=""
secondary_tbm=""

primary_tbms=(
    apt
    dnf
    eopkg
    pacman
    xbps-install
    zypper
)

secondary_tbms=(
    nala
    paru
    yay
)

if command -v toolbox >/dev/null 2>&1; then
    toolbox_installed=1
    for cmd in "${primary_tbms[@]}"; do
        if toolbox run bash -c "command -v $cmd >/dev/null 2>&1"; then
            primary_tbm="$cmd"
            break
        fi
    done

    for cmd in "${secondary_tbms[@]}"; do
        if toolbox run bash -c "command -v $cmd >/dev/null 2>&1"; then
            secondary_tbm="$cmd"
            break
        fi
    done
fi

# Normalizes xbps-install to xbps
if [ "$primary_tbm" = "xbps-install" ]; then
    primary_tbm="xbps"
fi

if [ -n "$primary_tbm" ]; then
    echo "${green}Primary Toolbox Manager:${reset} $primary_tbm"
fi

if [ -n "$secondary_tbm" ]; then
    echo "${green}Secondary Toolbox Manager:${reset} $secondary_tbm"
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
    package1
    package2
)

aur_packages=(
    package1
    package2
)

flatpaks=(
    flatpak
    flatpak2
)

snaps=(
    snap1
    snap2
)

# Checks for package manager and installs package(s)
case "$primary_pm" in
    apt)
        sudo apt-get install -y "${packages[@]}"
        ;;
    dnf)
        sudo dnf install -y "${packages[@]}"
        ;;
    eopkg)
        sudo eopkg install -y "${packages[@]}"
        ;;
    pacman)
        case "$secondary_pm" in
           paru|yay)
            "$secondary_pm" -S --needed --noconfirm "${aur_packages[@]}"
            ;;
        *)
            pacman -S --needed --noconfirm "${packages[@]}"
        fi
        ;;
    xbps)
        sudo xbps-install -Sy "${packages[@]}"
        ;;
    zypper)
        sudo zypper in -y "${packages[@]}"
        ;;
    rpm-ostree)
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
