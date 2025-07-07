#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for flatpak and flathub
if ! command -v flatpak > /dev/null 2>&1 || ! flatpak remote-list | grep -q "flathub"; then
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Detect main package manager
if command -v apt > /dev/null 2>&1; then
    main_package_manager="apt"
     
elif command -v dnf > /dev/null 2>&1; then
    main_package_manager="dnf"
    
elif command -v pacman > /dev/null 2>&1; then
    main_package_manager="pacman"
    
elif command -v xbps-install > /dev/null 2>&1; then
    main_package_manager="xbps"
    
elif command -v zypper > /dev/null 2>&1; then
    main_package_manager="zypper"

elif command -v rpm-ostree > /dev/null 2>&1; then
    main_package_manager="rpm-ostree"

else
    main_package_manager="unknown"
fi

# Detect secondary package manager
if command -v flatpak > /dev/null 2>&1; then
    secondary_package_manager="flatpak"

elif command -v snap > /dev/null 2>&1; then
    secondary_package_manager="snap"

else
    secondary_package_manager="unknown"
fi

# List of packages
packages=("librewolf")
aur_packages=("librewolf-bin")
flatpaks=("io.gitlab.librewolf-community")

# Checks for main package manager
if [ "$main_package_manager" = "apt" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo apt-get install -y extrepo
    
    # Enables external repo
    sudo extrepo enable librewolf
    sudo apt-get update && sudo apt-get install -y "${packages[@]}"

elif [ "$main_package_manager" = "dnf" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    # Adds repo(s)
    curl -fsSL https://repo.librewolf.net/librewolf.repo | pkexec tee /etc/yum.repos.d/librewolf.repo
    sudo dnf install -y "${packages[@]}"

elif [ "$main_package_manager" = "pacman" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    # Checks for AUR helper
    if [ "$aur_package_manager" ]; then
        echo "${green}Detected Package Manager: $aur_package_manager ${reset}"
        "$aur_package_manager" -S "${aur_packages[@]}"
    else
        sudo pacman -S --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ..
        rm -rf paru
        paru -S "${aur_packages[@]}"
    fi
    
elif [ "$main_package_manager" = "xbps" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    flatpak install flathub -y "${flatpaks[@]}"

elif [ "$main_package_manager" = "zypper" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    flatpak install flathub -y "${flatpaks[@]}"
    
elif [ "$secondary_package_manager" = "flatpak" ]; then
    echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
    flatpak install flathub -y "${flatpaks[@]}"

elif [ "$secondary_package_manager" = "snap" ]; then
    echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
    sudo snap install "${packages[@]}"
    
elif [ "$main_package_manager" = "rpm-ostree" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    flatpak install flathub -y "${flatpaks[@]}"
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi
    
# Prints a conclusive message
echo "${green}LibreWolf is now installed ${reset}"

