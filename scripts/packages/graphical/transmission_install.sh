#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Detect the operating system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "Unable to detect the operating system"
    exit 1
fi

# Convert operating system to lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Prints the detected operating system
echo "Detected (ID): $os"
echo "Detected (ID_LIKE): $os_like"

# Checks for flatpak and flathub
if ! command -v flatpak > /dev/null 2>&1 || ! flatpak remote-list | grep -q "flathub"; then
    # Runs script to install flatpak and set up flathub
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"

# Detect the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Prints the detected desktop
echo "Detected Desktop: $desktop"

# Checks for package manager
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
            # Installs package(s)
            sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y transmission-qt
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y transmission-gtk
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y transmission-qt
            ;;
        *)
            echo "Unsupported desktop"
            exit 1
            ;;
    esac
elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
            # Installs package(s)
            sudo dnf upgrade -y && sudo dnf install -y transmission-qt
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            sudo dnf upgrade -y && sudo dnf install -y transmission-gtk
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo dnf upgrade -y && sudo dnf install -y transmission-qt
            ;;
        *)
            echo "Unsupported desktop"
            exit 1
            ;;
    esac
elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
            # Installs package(s)
            sudo pacman -Syu --needed --noconfirm transmission-qt
            ;;
        "gnome"|"lxde"|"mate"|"xfce"|"x-cinnamon"|"budgie"|"cosmic"|"pantheon"|"unity")
            # Installs package(s)
            sudo pacman -Syu --needed --noconfirm transmission-gtk
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo pacman -Syu --needed --noconfirm transmission-qt
            ;;
        *)
            echo "Unsupported desktop"
            exit 1
            ;;
    esac
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y com.transmissionbt.Transmission
    
    # Adds package(s) to autostart
    cp -v /var/lib/flatpak/exports/share/applications/com.transmissionbt.Transmission.desktop "$HOME/.config/autostart/"
    
    # Prints a conclusive message
    echo "Transmission is now installed"
    exit 0
elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
            # Installs package(s)
            sudo xbps-install -Suy xbps && sudo xbps-install -uy && sudo xbps-install -y transmission-qt
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            sudo xbps-install -Suy xbps && sudo xbps-install -uy && sudo xbps-install -y transmission-gtk
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo xbps-install -Suy xbps && sudo xbps-install -uy && sudo xbps-install -y transmission-qt
            ;;
        *)
            echo "Unsupported desktop"
            exit 1
            ;;
    esac
elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
            # Installs package(s)
            if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
                sudo zypper ref && sudo zypper dup && sudo zypper in -y transmission-qt
            elif [ "$os" = "opensuse-leap" ]; then
                sudo zypper ref && sudo zypper up && sudo zypper in -y transmission-qt
            else
                echo "Unsupported operating system"
                exit 1
            fi
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
                sudo zypper ref && sudo zypper dup && sudo zypper in -y transmission-gtk
            elif [ "$os" = "opensuse-leap" ]; then
                sudo zypper ref && sudo zypper up && sudo zypper in -y transmission-gtk
            else
                echo "Unsupported operating system"
                exit 1
            fi
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
                sudo zypper ref && sudo zypper dup && sudo zypper in -y transmission-qt
            elif [ "$os" = "opensuse-leap" ]; then
                sudo zypper ref && sudo zypper up && sudo zypper in -y transmission-qt
            else
                echo "Unsupported operating system"
                exit 1
            fi
            ;;
        *)
            echo "Unsupported desktop"
            exit 1
            ;;
    esac
else
    echo "Unsupported package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y com.transmissionbt.Transmission
    
    # Adds package(s) to autostart
    cp -v /var/lib/flatpak/exports/share/applications/com.transmissionbt.Transmission.desktop "$HOME/.config/autostart/"
    
    # Prints a conclusive message
    echo "Transmission is now installed"
    exit 1
fi

# Adds package(s) to autostart
cp -v /usr/share/applications/transmission*.desktop "$HOME/.config/autostart/"

# Prints a conclusive message
echo "Transmission is now installed"


