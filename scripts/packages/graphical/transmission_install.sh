#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for flatpak and flathub
if ! command -v flatpak &> /dev/null || ! flatpak remote-list | grep -q "flathub"; then
    # Runs script to install flatpak and set up flathub
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"

# Detects the desktop environment and stores in a variable, then converts it into lowercase
desktop_env=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Prints the detected desktop environment
    echo "Detected: $desktop_env"

    # Conditional execution based on the desktop environment
    case "$desktop_env" in
        "gnome"|"lxde"|"mate"|"xfce"|"x-cinnamon"|"budgie"|"cosmic"|"pantheon"|"unity")
            # Installs package(s)
            sudo pacman -Syu --needed --noconfirm transmission-gtk
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo pacman -Syu --needed --noconfirm transmission-qt
            ;;
        *)
            echo "Unsupported desktop environment"
            read -p "Press enter to exit"
            exit 1
            ;;
    esac
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Prints the detected desktop environment
    echo "Detected: $desktop_env"

    # Conditional execution based on the desktop environment
    case "$desktop_env" in
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y transmission-gtk
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y transmission-qt
            ;;
        *)
            echo "Unsupported desktop environment"
            read -p "Press enter to exit"
            exit 1
            ;;
    esac
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Prints the detected desktop environment
    echo "Detected: $desktop_env"

    # Conditional execution based on the desktop environment
    case "$desktop_env" in
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            sudo dnf upgrade -y && sudo dnf install -y transmission-gtk
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo dnf upgrade -y && sudo dnf install -y transmission-qt
            ;;
        *)
            echo "Unsupported desktop environment"
            read -p "Press enter to exit"
            exit 1
            ;;
    esac
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Prints the detected desktop environment
    echo "Detected: $desktop_env"

    # Conditional execution based on the desktop environment
    case "$desktop_env" in
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            sudo zypper ref && sudo zypper dup -y && sudo zypper in -y transmission-gtk
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo zypper ref && sudo zypper dup -y && sudo zypper in -y transmission-qt
            ;;
        *)
            echo "Unsupported desktop environment"
            read -p "Press enter to exit"
            exit 1
            ;;
    esac
elif command -v xbps-install &> /dev/null; then
    echo "Detected: xbps"
    # Prints the detected desktop environment
    echo "Detected: $desktop_env"

    # Conditional execution based on the desktop environment
    case "$desktop_env" in
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            sudo xbps-install -Su xbps && sudo xbps-install -u && sudo xbps-install -y transmission-gtk
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo xbps-install -Su xbps && sudo xbps-install -u && sudo xbps-install -y transmission-qt
            ;;
        *)
            echo "Unsupported desktop environment"
            read -p "Press enter to exit"
            exit 1
            ;;
    esac
else
    echo "Unsupported package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y app/com.transmissionbt.Transmission/x86_64/stable
    
    # Adds package(s) to autostart
    cp -v /var/lib/flatpak/exports/share/applications/com.transmissionbt.Transmission.desktop "$HOME/.config/autostart/"
    
    # Prints a conclusive message
    echo "Transmission is now installed"
    read -p "Press enter to exit"
    exit 1
fi

# Adds package(s) to autostart
cp -v /usr/share/applications/transmission*.desktop "$HOME/.config/autostart/"

# Prints a conclusive message
echo "Transmission is now installed"
read -p "Press enter to exit"

