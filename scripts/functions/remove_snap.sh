#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# List of packages
packages=("snapd")
aur_packages=("snapd")

# Checks for init system
if ps -p 1 -o comm= | grep -Fq "systemd"; then
    echo "${green}Init System: systemd ${reset}"
else
    echo "${red}Unsupported init system. ${reset}"
    exit 1
fi

## Define primary and secondary package managers
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
    echo "${green}Primary Package Manager: $secondary_package_manager ${reset}"
fi

# Checks for Snap then removes all related packages
if command -v snap > /dev/null 2>&1; then

    # Disables snap daemon
    sudo systemctl disable --now snapd

    # Removes user-installed package(s)
    for user_package in $(snap list | awk '!/^Name/ {print $1}' | grep -v -E '^(bare|core|core18|core20|core22|snapd|gtk-common-themes)$'); do
        sudo snap remove --purge "$user_package"
    done

    # Removes theme/base package(s)
    for base_package in gtk-common-themes bare core core18 core20 core22 snapd; do
        if snap list | grep -q "^$base_package "; then
            sudo snap remove --purge "$base_package"
        fi
    done

    # Checks package manager and removes package(s)
    case "$primary_package_manager" in
        "apt")
            sudo apt-get purge -y "${packages[@]}"

            # Locks package(s) from being reinstalled automatically
            if ! apt-mark showhold | grep -q "^snapd$"; then
                sudo apt-mark hold snapd
            fi
            ;;
        "dnf")
            sudo dnf remove -y "${packages[@]}"
            ;;
        "eopkg")
            sudo eopkg remove -y "${packages[@]}"
            ;;
        "pacman")
            if [[ "$secondary_package_manager" =~ ^(paru|yay)$ ]]; then
                "$secondary_package_manager" -Rs --noconfirm "${aur_packages[@]}"
            else
                sudo pacman -S --needed --noconfirm base-devel git makepkg
                git clone https://aur.archlinux.org/paru.git
                cd paru
                makepkg -si --noconfirm
                cd ..
                rm -rf paru
                paru -Rs --noconfirm "${aur_packages[@]}"
            fi
            ;;
        "zypper")
            sudo zypper rm --clean-deps -y "${packages[@]}"

            # Removes repo(s)
            sudo zypper rr snappy
            ;;
        "rpm-ostree")
            if command -v "${packages[@]}" > /dev/null 2>&1; then
                sudo rpm-ostree remove "${packages[@]}"
            fi
            ;;
        *)
            echo "${red}Unsupported package manager. ${reset}"
            exit 1
            ;;
    esac

    # Removes directory(s)
    if [ -d /var/cache/snapd ]; then
        sudo rm -rfv /var/cache/snapd
    fi

    if [ -d /snap ]; then
        sudo rm -rfv /snap
    fi

    if [ -d "$HOME/snap" ]; then
        rm -rfv "$HOME/snap"
    fi

    # Prints a conclusive message
    echo "${green}Snap has been removed from system. ${reset}"

else
    echo "${yellow}Snap not detected. ${reset}"
    exit 1
fi
