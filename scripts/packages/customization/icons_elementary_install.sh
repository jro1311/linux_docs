#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
green=$(tput setaf 2)
yellow=$(tput setaf 3)
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

# Checks for package manager and installs package(s)
case "$primary_package_manager" in
    "apt")
        sudo apt-get install -y elementary-icon-theme
        ;;
    "dnf")
        sudo dnf install -y elementary-icon-theme
        ;;
    "pacman")
        sudo pacman -S --needed --noconfirm elementary-icon-theme
        ;;
    "zypper")
        sudo zypper in -y pantheon-icons
        ;;
    "rpm-ostree")
        sudo rpm-ostree install elementary-icon-theme
        ;;
    *)
        echo "${yellow}Manual installation required. ${reset}"
        echo "${yellow}Go to https://github.com/shimmerproject/elementary-xfce/ ${reset}"
        exit 0
        ;;
esac

# Prints a conclusive message
echo "${green}Elementary icons are now installed. ${reset}"

