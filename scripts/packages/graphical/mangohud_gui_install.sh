#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Runs script to install flatpak
chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
"$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"

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
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            flatpak update -y && flatpak install flathub -y mangojuice
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo pacman -S --needed --noconfirm goverlay
            ;;
        *)
            echo "Unsupported desktop environment"
            read -p "Press enter to exit"
            exit 1
            ;;
    esac
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y mangohud
    
    # Conditional execution based on the desktop environment
    case "$desktop_env" in
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            flatpak update -y && flatpak install flathub -y mangojuice
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo apt-get install -y goverlay
            ;;
        *)
            echo "Unsupported desktop environment"
            read -p "Press enter to exit"
            exit 1
            ;;
    esac
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y mangohud
    
    # Conditional execution based on the desktop environment
    case "$desktop_env" in
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            flatpak update -y && flatpak install flathub -y mangojuice
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo dnf install -y goverlay
            ;;
        *)
            echo "Unsupported desktop environment"
            read -p "Press enter to exit"
            exit 1
            ;;
    esac
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper ref && sudo zypper dup -y && sudo zypper in -y mangohud mangohud-32bit

    # Conditional execution based on the desktop environment
    case "$desktop_env" in
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            flatpak update -y && flatpak install flathub -y mangojuice
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo zypper in -y goverlay
            ;;
        *)
            echo "Unsupported desktop environment"
            read -p "Press enter to exit"
            exit 1
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
mkdir -pv "$HOME/.config/MangoHud"
mkdir -pv "$HOME/Documents/mangohud/logs"

# Enables nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Detects batteries and stores in a variable
batteries=(/sys/class/power_supply/BAT*)

# Checks for battery
if (( ${#batteries[@]} )); then
    echo "Detected System: Laptop"
    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud_laptop.conf" "$HOME/.config/MangoHud/"
    
    # Changes name(s)
    mv -v "$HOME/.config/MangoHud/MangoHud_laptop.conf" "$HOME/.config/MangoHud/MangoHud.conf"
else
    echo "Detected System: Desktop"
    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud.conf" "$HOME/.config/MangoHud/"
fi

# Prints a conclusive message
echo "mangohud + mangojuice/goverlay is now installed"
read -p "Press enter to exit"
