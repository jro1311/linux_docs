#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Detects the operating system and stores it in a variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "Unable to detect the operating system"
    read -p "Press enter to exit"
    exit 1
fi

# Converts the variable into lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Prints the detected operating system
echo "Detected (ID): $os"
echo "Detected (ID_LIKE): $os_like"

# Checks for flatpak and flathub
if ! command -v flatpak &> /dev/null || ! flatpak remote-list | grep -q "flathub"; then
    # Runs script to install flatpak and set up flathub
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"

# Detects the desktop environment or window manager, shortens it, then converts it into lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Prints the detected desktop
echo "Detected Desktop: $desktop"

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Conditional execution based on the desktop
    case "$desktop" in
        "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
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
            read -p "Press enter to exit"
            exit 1
            ;;
    esac
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Conditional execution based on the desktop
    case "$desktop" in
        "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
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
            read -p "Press enter to exit"
            exit 1
            ;;
    esac
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Conditional execution based on the desktop
    case "$desktop" in
        "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
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
            read -p "Press enter to exit"
            exit 1
            ;;
    esac
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Conditional execution based on the desktop
    case "$desktop" in
        "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
            # Installs package(s)
            if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
                sudo zypper ref && sudo zypper dup && sudo zypper in -y transmission-qt
            elif [ "$os" = "opensuse-leap" ]; then
                sudo zypper ref && sudo zypper up && sudo zypper in -y transmission-qt
            else
                echo "Unsupported operating system"
                read -p "Press enter to exit"
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
                read -p "Press enter to exit"
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
                read -p "Press enter to exit"
                exit 1
            fi
            ;;
        *)
            echo "Unsupported desktop"
            read -p "Press enter to exit"
            exit 1
            ;;
    esac
elif command -v xbps-install &> /dev/null; then
    echo "Detected: xbps"
    # Conditional execution based on the desktop
    case "$desktop" in
        "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
            # Installs package(s)
            sudo xbps-install -Su xbps && sudo xbps-install -u && sudo xbps-install -y transmission-qt
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            sudo xbps-install -Su xbps && sudo xbps-install -u && sudo xbps-install -y transmission-gtk
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo xbps-install -Su xbps && sudo xbps-install -u && sudo xbps-install -y transmission-qt
            ;;
        *)
            echo "Unsupported desktop"
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

