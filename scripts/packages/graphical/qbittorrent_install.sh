#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Define package managers
primary_package_manager="unknown"
primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)

for cmd in "${primary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        primary_package_manager="$cmd"
        break
    fi
done

if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    echo "${green}Primary Package Manager: $primary_package_manager ${reset}"
fi

# Check for Flatpak
flatpak_installed=0
if command -v flatpak > /dev/null 2>&1; then
    flatpak_installed=1
    echo "${green}Flatpak detected. ${reset}"
fi

# Check for Snap
snap_installed=0
if command -v snap > /dev/null 2>&1; then
    snap_installed=1
    echo "${green}Snap detected. ${reset}"
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"

# List of packages
packages=("qbittorrent")
flatpaks=("org.qbittorrent.qBittorrent")
snaps=("qbittorrent-arnatious")

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
        ;;

    "xbps")
        sudo xbps-install -Sy "${packages[@]}"
        ;;

    "zypper")
        sudo zypper in -y "${packages[@]}"
        ;;

    *)
        if [[ "$flatpak_installed" -eq 1 ]]; then
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            flatpak install flathub -y "${flatpaks[@]}"

            # Adds package(s) to autostart
            cp -v /var/lib/flatpak/exports/share/applications/org.qbittorrent.qBittorrent.desktop "$HOME/.config/autostart/"

            # Prints a conclusive message
            echo "${green}qBittorrent is now installed. ${reset}"
            exit 0

        elif [[ "$snap_installed" -eq 1 ]]; then
            sudo snap install "${snaps[@]}"

            # Adds package(s) to autostart
            cp -v /var/lib/snap/exports/share/applications/qbittorrent-arnatious.desktop "$HOME/.config/autostart/"

            # Prints a conclusive message
            echo "${green}qBittorrent is now installed. ${reset}"
            exit 0

        else
            echo "${red}Unsupported package manager. ${reset}"
            exit 1
        fi
        ;;
esac

# Adds package(s) to autostart
cp -v /usr/share/applications/org.qbittorrent.qBittorrent.desktop "$HOME/.config/autostart/"

# Prints a conclusive message
echo "${green}qBittorrent is now installed. ${reset}"



