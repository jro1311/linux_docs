#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Define package managers
primary_package_manager="unknown"
secondary_package_manager="unknown"

primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)
secondary_package_managers=(nala paru yay)

for cmd in "${primary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        primary_package_manager="$cmd"
        break
    fi
done

for cmd in "${secondary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        secondary_package_manager="$cmd"
        break
    fi
done

# Normalizes xbps-install to xbps
if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    echo "${green}Primary Package Manager: $primary_package_manager ${reset}"
fi

if [ "$secondary_package_manager" != "unknown" ]; then
    echo "${green}Secondary Package Manager: $secondary_package_manager ${reset}"
fi

# Check for Flatpak
flatpak_installed=0
if command -v flatpak >/dev/null 2>&1; then
    flatpak_installed=1
    echo "${green}Flatpak detected. ${reset}"
fi

# Check for Snap
snap_installed=0
if command -v snap >/dev/null 2>&1; then
    snap_installed=1
    echo "${green}Snap detected. ${reset}"
fi

# Define the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')
echo "${green}Desktop: $desktop ${reset}"

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"

# List of packages
flatpaks=("com.transmissionbt.Transmission")
snaps=("transmission")

declare -A transmission_gtk=(
    [apt]="transmission-gtk"
    [dnf]="transmission-gtk"
    [eopkg]="transmission"
    [pacman]="transmission-gtk"
    [xbps]="transmission-gtk"
    [zypper]="transmission-gtk"
)

declare -A transmission_qt=(
    [apt]="transmission-qt"
    [dnf]="transmission-qt"
    [eopkg]="transmission"
    [pacman]="transmission-qt"
    [xbps]="transmission-qt"
    [zypper]="transmission-qt"
)

ask_for_confirmation() {
    local prompt="$1"
    local answer

    while true; do
        read -r -p "$prompt [Y/n]: " answer
        answer="${answer:-y}"

        case "$answer" in
            [Yy]) return 0 ;;
            [Nn]) return 1 ;;
            *) echo "Enter a 'y' or 'n'." ;;
        esac
    done
}

install_packages() {
    local packages=("$@")
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y "${packages[@]}"
            ;;
        "dnf")
            sudo dnf install -y "${packages[@]}"
            ;;
        "eopkg")
            sudo eopkg install -y "${packages[@]}"
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm "${packages[@]}"
            ;;
        "xbps")
            sudo xbps-install -Sy "${packages[@]}"
            ;;
        "zypper")
            sudo zypper in -y "${packages[@]}"
            ;;
        *)
            if [ "$flatpak_installed" -eq 1 ]; then
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                flatpak install flathub -y "${flatpaks[@]}"

            elif [ "$snap_installed" -eq 1 ]; then
                sudo snap install "${snaps[@]}"

            else
                echo "${red}Unsupported package manager. ${reset}"
                exit 1
            fi
            ;;
    esac
}

# Checks for desktop and installs package(s)
case "$desktop" in
    "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
        install_packages "${transmission_qt[$primary_package_manager]}"
        ;;
    "budgie"|"cosmic"|"deepin"|"gnome"|"lxde"|"mate"|"pantheon"|"ubuntu"|"unity"|"x-cinnamon"|"xfce")
        install_packages "${transmission_gtk[$primary_package_manager]}"
        ;;
    "lxqt"|"kde"|"plasma")
        install_packages "${transmission_qt[$primary_package_manager]}"
        ;;
    *)
        install_packages "${transmission_gtk[$primary_package_manager]}"
        ;;
esac

# Prompts user to add package to autostart
if ask_for_confirmation "Add Transmission to autostart?"; then

    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/transmission.desktop" "$HOME/.config/autostart/"

    if command -v transmission-gtk >/dev/null 2>&1; then
        echo "Exec=transmission-gtk --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"
    
    elif command -v transmission-qt >/dev/null 2>&1; then
        echo "Exec=transmission-qt --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"
    
    elif [ "$flatpak_installed" -eq 1 ] && flatpak list | grep -Fq "com.transmissionbt.Transmission"; then
        echo "Exec=flatpak run com.transmissionbt.Transmission --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"

    elif [ "$snap_installed" -eq 1 ] && snap list | grep -Fiq "transmission"; then
        echo "Exec=snap run transmission --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"
    fi
    
fi

# Prints a conclusive message
echo "${green}Transmission is now installed. ${reset}"
