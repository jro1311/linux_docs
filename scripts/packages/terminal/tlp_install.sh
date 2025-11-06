#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Define primary package manager
if command -v apt > /dev/null 2>&1; then
    primary_package_manager="apt"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v dnf > /dev/null 2>&1; then
    primary_package_manager="dnf"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

elif command -v eopkg > /dev/null 2>&1; then
    primary_package_manager="eopkg"
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

# Checks for flatpak and flathub
if ! command -v flatpak > /dev/null 2>&1 || ! flatpak remote-list | grep -q "flathub"; then

    # Runs script to install flatpak and set up flathub
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"

fi

# Define secondary package manager
if command -v flatpak > /dev/null 2>&1; then
    secondary_package_manager="flatpak"
    echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
    
else
    secondary_package_manager="unknown"
fi

# Define init system
if ps -p 1 -o comm= | grep -Fq "systemd"; then
    init_system="systemd"
    echo "${green}Detected Init System: $init_system ${reset}"

elif ps -p 1 -o comm= | grep -Fq "runit"; then
    init_system="runit"
    echo "${green}Detected Init System: $init_system ${reset}"

else
    init_system="unknown"
fi

# List of packages
packages=("tlp")
flatpaks=("com.github.d4nj1.tlpui")

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then
    sudo apt-get install -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "dnf" ]; then
    sudo dnf install -y "${packages[@]}"

elif [ "$primary_package_manager" = "eopkg" ]; then
    sudo eopkg install -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "pacman" ]; then
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
elif [ "$primary_package_manager" = "xbps" ]; then
    sudo xbps-install -Sy "${packages[@]}"
    
elif [ "$primary_package_manager" = "zypper" ]; then
    sudo zypper in -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "rpm-ostree" ]; then

    if ! command -v "${packages[@]}" > /dev/null 2>&1; then
        sudo rpm-ostree install "${packages[@]}"
        echo "${yellow}Reboot and run script again to complete. ${reset}"
        exit 0
    fi
    
else
    echo "${red}Unsupported package manager. ${reset}"
    exit 1
fi

# Checks for package manager and installs package(s)
if [ "$secondary_package_manager" = "flatpak" ]; then
    flatpak install flathub -y "${flatpaks[@]}"
fi

# Checks for init system and enables TLP service
if [ "$init_system" = "systemd" ]; then
    sudo systemctl enable --now tlp.service

elif [ "$init_system" = "runit" ]; then
    sudo ln -s /etc/sv/tlp /var/service
    
else
    echo "{$red}Unsupported init system. ${reset}"
    exit 1
fi

# Prints a conclusive message
echo "${green}TLP is now installed. ${reset}"

