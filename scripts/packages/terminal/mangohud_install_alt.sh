#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    echo "Alternate installation is not necessary. Run normal mangohud_setup.sh instead."
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt update && sudo apt upgrade -y && sudo apt install -y libfmt9 libspdlog1.12 libqt5pas1 libqt5printsupport5t64 libqt5x11extras5 vkbasalt vulkan tools

    # Installs libqt6pas that isn't provided by official repo
    wget -O $HOME/Downloads/libqt6pas6_6.2.10-1_amd64.deb "https://github.com/davidbannon/libqt6pas/releases/download/v6.2.10/libqt6pas6_6.2.10-1_amd64.deb"
    sudo nala install -y $HOME/Downloads/libqt6pas6_6.2.10-1_amd64.deb

    # Downloads and installs the latest MangoHud build
    wget -O $HOME/Downloads/MangoHud-0.8.1.r0.gfea4292.tar.gz "https://github.com/flightlessmango/MangoHud/releases/download/v0.8.1/MangoHud-0.8.1.r0.gfea4292.tar.gz"
    tar -xvf $HOME/Downloads/MangoHud-0.8.1.r0.gfea4292.tar.gz -C $HOME/Downloads/
    $HOME/Downloads/MangoHud/mangohud-setup.sh install
    rm -v $HOME/Downloads/MangoHud-0.8.1.r0.gfea4292.tar.gz

    # Downloads latest Goverlay build as an AppImage
    wget -O $HOME/Downloads/GOverlay-git-anylinux-x86_64.AppImage  "https://github.com/benjamimgois/goverlay/releases/download/1.3-3/GOverlay-git-anylinux-x86_64.AppImage"
    chmod +x $HOME/Downloads/GOverlay-git-anylinux-x86_64.AppImage

    # Installs package(s)
    flatpak update -y && flatpak install -y runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08

    # Makes directory(s)
    mkdir -pv $HOME/.config/MangoHud
    mkdir -pv $HOME/Documents/mangohud/logs

    # Function to check for battery presence
    check_battery() {
        if [ -d /sys/class/power_supply/BAT0 ] || [ -d /sys/class/power_supply/BAT1 ]; then
            return 0  # Battery detected
        else
            return 1  # No battery detected
        fi
    }

    # Check for battery
    if check_battery; then
        echo "Battery detected"
        # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/MangoHud_laptop.conf $HOME/.config/MangoHud/
        
        # Changes name(s)
        mv -v $HOME/.config/MangoHud/MangoHud_laptop.conf $HOME/.config/MangoHud/MangoHud.conf
    else
        echo "No battery detected"
        # Copies config(s) to the system
        cp -v $HOME/Documents/linux_docs/configs/packages/MangoHud.conf $HOME/.config/MangoHud/
    fi
    # Prints a conclusive message to end the script
    echo "MangoHud and goverlay are now installed. Use Goverlay by executing the AppImage in $HOME/Downloads directory."
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    echo "Alternate installation is not necessary. Run mangohud_setup.sh instead."
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    echo "Alternate installation is not necessary. Run mangohud_setup.sh instead."
else
    echo "Unknown package manager"
    exit 1
fi

