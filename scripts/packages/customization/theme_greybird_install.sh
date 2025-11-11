#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Define the operating system and convert it to lowercase
if [ -f /etc/os-release ]; then
    . /etc/os-release

    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"

    os="${os,,}"
    os_like="${os_like,,}"

    echo "${green}Distro (ID): $os ${reset}"
    echo "${green}Distro (ID_LIKE): $os_like ${reset}"

else
    echo "${red}Unable to detect the operating system. ${reset}"
    exit 1
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
        sudo apt-get install -y greybird-gtk-theme
        ;;
    "dnf")
        if [ "$os" = "openmandriva" ]; then
            echo "${yellow}Manual installation required. ${reset}"
            echo "${yellow}Go to https://github.com/shimmerproject/Greybird/ ${reset}"
            exit 0
        else
            sudo dnf install -y greybird-dark-theme greybird-light-theme
        fi
        ;;
    "pacman")
        if [[ "$secondary_package_manager" =~ ^(paru|yay)$ ]]; then
            "$secondary_package_manager" -S xfce-theme-greybird
        else
            sudo pacman -S --needed --noconfirm base-devel git makepkg
            git clone https://aur.archlinux.org/paru.git
            cd paru
            makepkg -si --noconfirm
            cd ..
            rm -rf paru
            paru -S xfce-theme-greybird
        fi
        ;;
    xbps)
        sudo xbps-install -Sy greybird-themes
        ;;
    "zypper")
        sudo zypper in -y metatheme-greybird-common
        ;;
    "rpm-ostree")
        sudo rpm-ostree install greybird-dark-theme greybird-light-theme
        ;;
    *)
        echo "${yellow}Manual installation required. ${reset}"
        echo "${yellow}Go to https://github.com/shimmerproject/Greybird/ ${reset}"
        exit 0
        ;;
esac

# Prints a conclusive message
echo "${green}Greybird theme is now installed. ${reset}"

