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

# Detect the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Prints the detected desktop
echo "Detected Desktop: $desktop"

# Checks for package manager
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y mangohud
    
    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
            # Installs package(s)
            sudo apt-get install -y goverlay
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            flatpak update -y && flatpak install flathub -y mangojuice
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo apt-get install -y goverlay
            ;;
        *)
            echo "Unsupported"
            exit 1
            ;;
    esac
elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y mangohud
    
    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
            # Installs package(s)
            sudo dnf install -y goverlay
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            flatpak update -y && flatpak install flathub -y mangojuice
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo dnf install -y goverlay
            ;;
        *)
            echo "Unsupported desktop"
            exit 1
            ;;
    esac
elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm mangohud lib32-mangohud
    
    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
            # Installs package(s)
            sudo pacman -S --needed --noconfirm goverlay
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            flatpak update -y && flatpak install flathub -y mangojuice
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo pacman -S --needed --noconfirm goverlay
            ;;
        *)
            echo "Unsupported desktop"
            exit 1
            ;;
    esac
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    sudo rpm-ostree upgrade && sudo rpm-ostree install mangohud
    
    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
            # Installs package(s)
            sudo rpm-ostree install goverlay
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            flatpak update -y && flatpak install flathub -y mangojuice
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo rpm-ostree install goverlay
            ;;
        *)
            echo "Unsupported desktop"
            exit 1
            ;;
    esac
elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
     # Installs package(s)
    sudo xbps-install -Suy xbps && sudo xbps-install -uy && sudo xbps-install -y MangoHud MangoHud-32bit

    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
            # Installs package(s)
            sudo xbps-install -y goverlay
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            flatpak update -y && flatpak install flathub -y mangojuice
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo xbps-install -y goverlay
            ;;
        *)
            echo "Unsupported desktop"
            exit 1
            ;;
    esac
elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    # Installs package(s)
    if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
        sudo zypper ref && sudo zypper dup -y && sudo zypper in -y mangohud mangohud-32bit
    elif [ "$os" = "opensuse-leap" ]; then
        sudo zypper ref && sudo zypper up -y && sudo zypper in -y mangohud mangohud-32bit
    else
        echo "Unsupported operating system"
        exit 1
    fi

    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
            # Installs package(s)
            sudo zypper in -y goverlay
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            # Installs package(s)
            flatpak update -y && flatpak install flathub -y mangojuice
            ;;
        "deepin"|"lxqt"|"plasma")
            # Installs package(s)
            sudo zypper in -y goverlay
            ;;
        *)
            echo "Unsupported desktop"
            exit 1
            ;;
    esac
else
    echo "Unsupported package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y mangojuice
fi

# Installs package(s)
flatpak update -y && flatpak install org.freedesktop.Platform.VulkanLayer.MangoHud

# Makes directory(s)
mkdir -pv "$HOME/.config/MangoHud"
mkdir -pv "$HOME/Documents/mangohud/logs"

# Enables nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Detect batteries
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
echo "MangoHud + MangoJuice/Goverlay is now installed"

