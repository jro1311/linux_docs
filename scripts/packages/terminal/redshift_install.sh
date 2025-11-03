#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

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

# List of packages
packages=("jq" "redshift-gtk")

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then
    sudo apt-get install -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "dnf" ]; then
    sudo dnf install -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "pacman" ]; then
    sudo pacman -S --needed --noconfirm jq redshift
    
elif [ "$primary_package_manager" = "xbps" ]; then
    sudo xbps-install -Sy "${packages[@]}"
    
elif [ "$primary_package_manager" = "zypper" ]; then
    sudo zypper in -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "rpm-ostree" ]; then
    sudo rpm-ostree install "${packages[@]}"
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"

# Checks for package
if command -v redshift-gtk > /dev/null 2>&1; then

    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/redshift/redshift.conf" "$HOME/.config/"

    # Define coordinates
    location=$(curl -s "http://ipinfo.io/$(curl -s api.ipify.org)/json")
    latitude=$(echo "$location" | jq -r '.loc' | cut -d',' -f1)
    longitude=$(echo "$location" | jq -r '.loc' | cut -d',' -f2)

    # Adds coordinates to config(s)
    echo "lat=$latitude" >> "$HOME/.config/redshift.conf"
    echo "lon=$longitude" >> "$HOME/.config/redshift.conf"

    # Adds package(s) to autostart
    cp -v "$HOME/Documents/linux_docs/configs/packages/redshift/redshift.desktop" "$HOME/.config/autostart/"
    echo "Exec=redshift-gtk" >> "$HOME/.config/autostart/redshift.desktop"

elif command -v redshift > /dev/null 2>&1; then

    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/redshift/redshift.conf" "$HOME/.config/"

    # Define coordinates
    location=$(curl -s "http://ipinfo.io/$(curl -s api.ipify.org)/json")
    latitude=$(echo "$location" | jq -r '.loc' | cut -d',' -f1)
    longitude=$(echo "$location" | jq -r '.loc' | cut -d',' -f2)

    # Adds coordinates to config(s)
    echo "lat=$latitude" >> "$HOME/.config/redshift.conf"
    echo "lon=$longitude" >> "$HOME/.config/redshift.conf"

    # Adds package(s) to autostart
    cp -v "$HOME/Documents/linux_docs/configs/packages/redshift/redshift.desktop" "$HOME/.config/autostart/"
    echo "Exec=redshift" >> "$HOME/.config/autostart/redshift.desktop"

fi

# Prints a conclusive message
echo "${green}Redshift is now installed. ${reset}"

