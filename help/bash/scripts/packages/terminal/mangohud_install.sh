#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Checks for package manager and installs package(s)
if command -v apt > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: apt ${reset}"
    sudo apt-get install -y mangohud
    
elif command -v dnf > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: dnf ${reset}"
    sudo dnf install -y mangohud
    
elif command -v pacman > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: pacman ${reset}"
    sudo pacman -S --needed --noconfirm mangohud lib32-mangohud
    
elif command -v xbps-install > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: xbps ${reset}"
    sudo xbps-install -Sy MangoHud MangoHud-32bit
    
elif command -v zypper > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: zypper ${reset}"
    sudo zypper in -y mangohud mangohud-32bit
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: rpm-ostree ${reset}"
    rpm-ostree install mangohud

else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Checks for flatpak and flathub
if ! command -v flatpak > /dev/null 2>&1 || ! flatpak remote-list | grep -q "flathub"; then
    # Runs script to install flatpak and set up flathub
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Installs package(s)
flatpak install -y runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08

# Makes directory(s)
mkdir -pv "$HOME/.config/MangoHud"
mkdir -pv "$HOME/Documents/mangohud/logs"

# Enables nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Detect batteries
batteries=(/sys/class/power_supply/BAT*)

# Checks for battery
if (( ${#batteries[@]} )); then
    echo "${green}Detected System: Laptop ${reset}"
    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud_laptop.conf" "$HOME/.config/MangoHud/"
        
    # Changes name(s)
    mv -v "$HOME/.config/MangoHud/MangoHud_laptop.conf" "$HOME/.config/MangoHud/MangoHud.conf"
else
    echo "${green}Detected System: Desktop ${reset}"
    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud.conf" "$HOME/.config/MangoHud/"
fi

# Prints a conclusive message
echo "${green}MangoHud is now installed ${reset}"

