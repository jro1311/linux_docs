#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Detect the operating system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "${red}Unable to detect the operating system ${reset}"
    exit 1
fi

# Convert operating system to lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Checks for package manager and installs package(s)
if command -v apt > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: apt ${reset}"
    sudo apt-get install -y greybird-gtk-theme

elif command -v dnf > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: dnf ${reset}"
    if [ "$os" = "openmandriva" ]; then
        echo "${green}Detected Distro (ID): $os ${reset}"
        echo "${yellow}Manual installation required ${reset}"
        echo "${yellow}Go to https://github.com/shimmerproject/Greybird/ ${reset}"
        exit 0
    else 
        sudo dnf install -y greybird-dark-theme greybird-light-theme
    fi

elif command -v pacman > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: pacman ${reset}"
    if command -v paru > /dev/null 2>&1; then
        echo "${green}Detected Package Manager: paru ${reset}"
        paru -S xfce-theme-greybird
    elif command -v yay > /dev/null 2>&1; then
        echo "${green}Detected Package Manager: yay ${reset}"
        yay -S xfce-theme-greybird
    else
        sudo pacman -S --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ..
        rm -rf paru
        paru -S xfce-theme-greybird
    fi

elif command -v xbps-install > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: xbps ${reset}"
    echo "${yellow}Manual installation required ${reset}"
    echo "${yellow}Go to https://github.com/shimmerproject/Greybird/ ${reset}"
    exit 0

elif command -v zypper > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: zypper ${reset}"
    echo "${yellow}Manual installation required ${reset}"
    echo "${yellow}Go to https://github.com/shimmerproject/Greybird/ ${reset}"
    exit 0

elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: rpm-ostree ${reset}"
    sudo rpm-ostree install greybird-dark-theme greybird-light-theme

else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Prints a conclusive message
echo "${green}Greybird theme is now installed${reset}"

