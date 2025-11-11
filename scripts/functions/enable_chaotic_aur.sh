#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Checks for package manager
if command -v pacman > /dev/null 2>&1; then

    # Checks for Chaotic AUR
    if ! grep -Fq "chaotic" /etc/pacman.conf; then
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
        sudo tee -a /etc/pacman.conf <<-'EOF'
        [chaotic-aur]
            Include = /etc/pacman.d/chaotic-mirrorlist

EOF
    else
        echo "${green}Chaotic AUR is already enabled. ${reset}"
        exit 0
    fi

else
    echo "${red}Unsupported package manager. ${reset}"
    exit 1
fi

# Prints a conclusive message
echo "${green}Enabled: Chaotic AUR ${reset}"
