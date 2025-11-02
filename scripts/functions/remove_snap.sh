#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for init system
if ps -p 1 -o comm= | grep -Fq "systemd"; then
    echo "${green}Detected Init System: systemd ${reset}"
else
    echo "${red}Unsupported init system ${reset}"
    exit 1
fi

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
packages=("snapd")
aur_packages=("snapd")

# Checks for package
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

    # Checks for package manager and removes package(s)
    if [ "$primary_package_manager" = "apt" ]; then

        sudo apt-get purge -y "${packages[@]}"

        # Locks package(s) from being reinstalled automatically
        if ! apt-mark showhold | grep -q "^snapd$"; then
            sudo apt-mark hold snapd
        fi

    elif [ "$primary_package_manager" = "dnf" ]; then
        sudo dnf remove -y "${packages[@]}"

    elif [ "$primary_package_manager" = "pacman" ]; then

        # Checks for AUR package manager
        if [ "$aur_package_manager" != "unknown" ]; then
            "$aur_package_manager" -Rs --noconfirm "${aur_packages[@]}"
        else
            sudo pacman -S --needed --noconfirm base-devel git makepkg
            git clone https://aur.archlinux.org/paru.git
            cd paru
            makepkg -si --noconfirm
            cd ..
            rm -rf paru
            paru -Rs --noconfirm "${aur_packages[@]}"
        fi

    elif [ "$primary_package_manager" = "zypper" ]; then
        sudo zypper rm --clean-deps -y "${packages[@]}"

        # Removes repo(s)
        sudo zypper rr snappy

    elif [ "$primary_package_manager" = "rpm-ostree" ]; then

        if command -v "${packages[@]}" > /dev/null 2>&1; then
            sudo rpm-ostree remove "${packages[@]}"
        fi

    else
        echo "${red}Unsupported package manager ${reset}"
        exit 1
    fi

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
    echo "${green}Snap removed ${reset}"

else
    echo "${yellow}Snap not detected ${reset}"
    exit 1
fi
