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

# Checks for flatpak and flathub
if ! command -v flatpak > /dev/null 2>&1 || ! flatpak remote-list | grep -q "flathub"; then
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Define secondary package manager
if command -v flatpak > /dev/null 2>&1; then
    secondary_package_manager="flatpak"
    echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
    
else
    secondary_package_manager="unknown"
fi

# Define the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')
echo "${green}Detected Desktop: $desktop ${reset}"

# Lists of packages
packages=("goverlay")
auto_flatpaks=("io.github.radiolamp.mangojuice")
manual_flatpaks=("org.freedesktop.Platform.VulkanLayer.MangoHud")

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then
    sudo apt-get install -y mangohud
    
    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
            sudo apt-get install -y "${packages[@]}"
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            flatpak install flathub -y "${auto_flatpaks[@]}"
            ;;
        "deepin"|"lxqt"|"plasma")
            sudo apt-get install -y "${packages[@]}"
            ;;
        *)
            echo "${red}Unsupported desktop ${reset}"
            exit 1
            ;;
    esac
    
elif [ "$primary_package_manager" = "dnf" ]; then
    sudo dnf install -y mangohud
    
    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
            sudo dnf install -y "${packages[@]}"
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            flatpak install flathub -y "${auto_flatpaks[@]}"
            ;;
        "deepin"|"lxqt"|"plasma")
            sudo dnf install -y "${packages[@]}"
            ;;
        *)
            echo "${red}Unsupported desktop ${reset}"
            exit 1
            ;;
    esac
    
elif [ "$primary_package_manager" = "pacman" ]; then
    sudo pacman -S --needed --noconfirm mangohud lib32-mangohud
    
    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
            sudo pacman -S --needed --noconfirm "${packages[@]}"
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            flatpak install flathub -y "${auto_flatpaks[@]}"
            ;;
        "deepin"|"lxqt"|"plasma")
            sudo pacman -S --needed --noconfirm "${packages[@]}"
            ;;
        *)
            echo "${red}Unsupported desktop ${reset}"
            exit 1
            ;;
    esac
    
elif [ "$primary_package_manager" = "xbps" ]; then
    sudo xbps-install -Sy MangoHud MangoHud-32bit

    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
            sudo xbps-install -y "${packages[@]}"
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            flatpak install flathub -y "${auto_flatpaks[@]}"
            ;;
        "deepin"|"lxqt"|"plasma")
            sudo xbps-install -y "${packages[@]}"
            ;;
        *)
            echo "${red}Unsupported desktop ${reset}"
            exit 1
            ;;
    esac
    
elif [ "$primary_package_manager" = "zypper" ]; then
    sudo zypper in -y mangohud mangohud-32bit

    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
            sudo zypper in -y "${packages[@]}"
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            flatpak install flathub -y "${auto_flatpaks[@]}"
            ;;
        "deepin"|"lxqt"|"plasma")
            sudo zypper in -y "${packages[@]}"
            ;;
        *)
            echo "${red}Unsupported desktop ${reset}"
            exit 1
            ;;
    esac
    
elif [ "$primary_package_manager" = "rpm-ostree" ]; then
    
    # Executes commands based on the desktop
    case "$desktop" in
        "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
            sudo rpm-ostree install "${packages[@]}"
            ;;
        "budgie"|"cosmic"|"gnome"|"lxde"|"mate"|"pantheon"|"unity"|"xfce"|"x-cinnamon")
            flatpak install flathub -y "${auto_flatpaks[@]}"
            ;;
        "deepin"|"lxqt"|"plasma")
            sudo rpm-ostree install "${packages[@]}"
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

# Checks for package manager and installs package(s)
if [ "$secondary_package_manager" = "flatpak" ]; then
    flatpak install flathub "${manual_flatpaks[@]}"

else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

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
    cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud.conf" "$HOME/.config/MangoHud/"
    
    # Edits FPS limits
    sed -i 's/fps_limit=160,120,90,60,30,0/fps_limit=60,30,0/' "$HOME/.config/MangoHud/MangoHud.conf"
else
    echo "${green}Detected System: Desktop ${reset}"
    
    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud.conf" "$HOME/.config/MangoHud/"
fi

# Prints a conclusive message
echo "${green}MangoHud + MangoJuice/Goverlay is now installed ${reset}"

