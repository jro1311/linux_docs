#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Runs script to install flatpak
chmod +x $HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh
$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh

# Detects the desktop environment and stores in a variable, then converts it into lowercase
desktop_env=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Prints the detected desktop environment
echo "Detected: $desktop_env"

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm mangohud lib32-mangohud
    
    # Conditional execution based on the desktop environment
    case "$desktop_env" in
        "gnome"|"lxde"|"mate"|"xfce"|"x-cinnamon"|"budgie")
            # Installs package(s)
            flatpak update -y && flatpak install flathub -y mangojuice
            ;;
        "plasma"|"lxqt")
            # Installs package(s)
            sudo pacman -S --needed --noconfirm goverlay
            ;;
        *)
            echo "Nothing to do for $desktop_env"
            ;;
    esac
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt update && sudo apt upgrade -y && sudo apt install -y mangohud
    
    # Conditional execution based on the desktop environment
    case "$desktop_env" in
        "gnome"|"lxde"|"mate"|"xfce"|"x-cinnamon"|"budgie")
            # Installs package(s)
            flatpak update -y && flatpak install flathub -y mangojuice
            ;;
        "plasma"|"lxqt")
            # Installs package(s)
            sudo apt install -y goverlay
            ;;
        *)
            echo "Nothing to do for $desktop_env"
            ;;
    esac
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y mangohud
    
    # Conditional execution based on the desktop environment
    case "$desktop_env" in
        "gnome"|"lxde"|"mate"|"xfce"|"x-cinnamon"|"budgie")
            # Installs package(s)
            flatpak update -y && flatpak install flathub -y mangojuice
            ;;
        "plasma"|"lxqt")
            # Installs package(s)
            sudo dnf install -y goverlay
            ;;
        *)
            echo "Nothing to do for $desktop_env"
            ;;
    esac
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper ref && sudo zypper -y dup && sudo zypper in -y mangohud mangohud-32bit

    # Conditional execution based on the desktop environment
    case "$desktop_env" in
        "gnome"|"lxde"|"mate"|"xfce"|"x-cinnamon"|"budgie")
            # Installs package(s)
            flatpak update -y && flatpak install flathub -y mangojuice
            ;;
        "plasma"|"lxqt")
            # Installs package(s)
            sudo zypper in -y goverlay
            ;;
        *)
            echo "Nothing to do for $desktop_env"
            ;;
    esac
else
    echo "Unknown package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y mangojuice
fi

# Installs package(s)
flatpak update -y && flatpak install -y runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08

# Makes directory(s)
mkdir -pv $HOME/.config/MangoHud
mkdir -pv $HOME/Documents/MangoHud/logs

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
    mv -v $HOME/.config/MangoHud/MangoHud_laptop.conf $HOME/.config/MangoHud/MangoHud.conf
else
    echo "No battery detected"
    # Copies config(s)
    cp -v $HOME/Documents/linux_docs/configs/packages/MangoHud.conf $HOME/.config/MangoHud/
fi

# Prints a conclusive message to end the script
echo "MangoHud + MangoJuice/Goverlay is now installed."
