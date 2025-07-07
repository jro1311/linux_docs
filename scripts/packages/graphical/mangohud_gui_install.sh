#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Checks for flatpak and flathub
if ! command -v flatpak > /dev/null 2>&1 || ! flatpak remote-list | grep -q "flathub"; then
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Detect the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Prints the detected desktop
echo "Detected Desktop: $desktop"

packages=("goverlay")
flatpaks=("io.github.radiolamp.mangojuice")

# Checks for package manager and installs package(s)
if command -v apt > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: apt ${reset}"
    sudo apt-get install -y mangohud
    
    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
            sudo apt-get install -y goverlay
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            flatpak install flathub -y mangojuice
            ;;
        "deepin"|"lxqt"|"plasma")
            sudo apt-get install -y goverlay
            ;;
        *)
            echo "${red}Unsupported desktop ${reset}"
            exit 1
            ;;
    esac
    
elif command -v dnf > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: dnf ${reset}"
    sudo dnf install -y mangohud
    
    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
            sudo dnf install -y goverlay
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            flatpak install flathub -y mangojuice
            ;;
        "deepin"|"lxqt"|"plasma")
            sudo dnf install -y goverlay
            ;;
        *)
            echo "${red}Unsupported desktop ${reset}"
            exit 1
            ;;
    esac
    
elif command -v pacman > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: pacman ${reset}"
    sudo pacman -S --needed --noconfirm mangohud lib32-mangohud
    
    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
            sudo pacman -S --needed --noconfirm goverlay
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            flatpak install flathub -y mangojuice
            ;;
        "deepin"|"lxqt"|"plasma")
            sudo pacman -S --needed --noconfirm goverlay
            ;;
        *)
            echo "${red}Unsupported desktop ${reset}"
            exit 1
            ;;
    esac
    
elif command -v xbps-install > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: xbps ${reset}"
    sudo xbps-install -Sy MangoHud MangoHud-32bit

    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
            sudo xbps-install -y goverlay
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            flatpak install flathub -y mangojuice
            ;;
        "deepin"|"lxqt"|"plasma")
            sudo xbps-install -y goverlay
            ;;
        *)
            echo "${red}Unsupported desktop ${reset}"
            exit 1
            ;;
    esac
    
elif command -v zypper > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: zypper ${reset}"
    sudo zypper in -y mangohud mangohud-32bit

    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
            sudo zypper in -y goverlay
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            flatpak install flathub -y mangojuice
            ;;
        "deepin"|"lxqt"|"plasma")
            sudo zypper in -y goverlay
            ;;
        *)
            echo "${red}Unsupported desktop ${reset}"
            exit 1
            ;;
    esac
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: rpm-ostree ${reset}"
    sudo rpm-ostree install mangohud
    
    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
            sudo rpm-ostree install goverlay
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            flatpak install flathub -y mangojuice
            ;;
        "deepin"|"lxqt"|"plasma")
            sudo rpm-ostree install goverlay
            ;;
        *)
            echo "${red}Unsupported desktop ${reset}"
            exit 1
            ;;
    esac

else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Installs package(s)
flatpak install org.freedesktop.Platform.VulkanLayer.MangoHud

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
echo "${green}MangoHud + MangoJuice/Goverlay is now installed ${reset}"

