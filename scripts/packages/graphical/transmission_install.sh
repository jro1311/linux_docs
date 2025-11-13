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
if command -v flatpak > /dev/null 2>&1; then
    flatpak_installed=1
    echo "${green}Flatpak detected. ${reset}"
fi

# Check for Snap
snap_installed=0
if command -v snap > /dev/null 2>&1; then
    snap_installed=1
    echo "${green}Snap detected. ${reset}"
fi

# Define the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')
echo "${green}Desktop: $desktop ${reset}"

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"

# Checks for package manager
if [[ ! "$primary_package_manager" =~ ^(rpm-ostree|eopkg)$ ]]; then

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
fi

# List of packages
gtk_packages=("transmission-gtk")
qt_packages=("transmission-qt")
flatpaks=("com.transmissionbt.Transmission")
snaps=("transmission")

# Calls function
if ask_for_confirmation "Install GTK or Qt version, or cancel (g/q/c)?"; then
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y "${gtk_packages[@]}"
            ;;
        "dnf")
            sudo dnf install -y "${gtk_packages[@]}"
            ;;
        "eopkg")
            sudo eopkg install -y transmission
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm "${gtk_packages[@]}"
            ;;
        "xbps")
            sudo xbps-install -Sy "${gtk_packages[@]}"
            ;;
        "zypper")
            sudo zypper in -y "${gtk_packages[@]}"
            ;;
        *)
            if [[ "$flatpak_installed" -eq 1 ]]; then
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                flatpak install flathub -y "${flatpaks[@]}"

            elif [[ "$snap_installed" -eq 1 ]]; then
                sudo snap install "${snaps[@]}"

            else
                echo "${red}Unsupported package manager. ${reset}"
                exit 1
            fi
            ;;
    esac
else
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y "${qt_packages[@]}"
            ;;
        "dnf")
            sudo dnf install -y "${qt_packages[@]}"
            ;;
        "eopkg")
            sudo eopkg install -y transmission
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm "${qt_packages[@]}"
            ;;
        "xbps")
            sudo xbps-install -Sy "${qt_packages[@]}"
            ;;
        "zypper")
            sudo zypper in -y "${qt_packages[@]}"
            ;;
        *)
            if [[ "$flatpak_installed" -eq 1 ]]; then
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                flatpak install flathub -y "${flatpaks[@]}"

            elif [[ "$snap_installed" -eq 1 ]]; then
                sudo snap install "${snaps[@]}"

            else
                echo "${red}Unsupported package manager. ${reset}"
                exit 1
            fi
            ;;
    esac
fi

# Calls function
if ask_for_confirmation "Add Transmission to autostart?"; then

    # Adds package(s) to autostart
    cp -v "$HOME/Documents/linux_docs/configs/packages/transmission.desktop" "$HOME/.config/autostart/"

    if command -v transmission-gtk > /dev/null 2>&1; then
        echo "Exec=transmission-gtk --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"
    
    elif command -v transmission-qt > /dev/null 2>&1; then
        echo "Exec=transmission-qt --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"
    
    elif [ "$flatpak_installed" -eq 1 ] && flatpak list | grep -Fq "com.transmissionbt.Transmission"; then
        echo "Exec=flatpak run com.transmissionbt.Transmission --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"

    elif [ "$snap_installed" -eq 1 ] && snap list | grep -Fiq "transmission"; then
        echo "Exec=snap run transmission --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"
    fi
    
fi

# Prints a conclusive message
echo "${green}Transmission is now installed. ${reset}"
