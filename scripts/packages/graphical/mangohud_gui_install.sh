#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
green=$(tput setaf 2)
reset=$(tput sgr0)

# Enables nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Detect host system
host_system="unknown"
batteries=(/sys/class/power_supply/BAT*)

if (( ${#batteries[@]} )); then
    host_system="laptop"
else
    host_system="desktop"
fi

if [ "$host_system" != "unknown" ]; then
    echo "${green}Host System: $host_system ${reset}"
fi

# Disables nullglob
shopt -u nullglob

# Define package managers
primary_package_manager="unknown"
primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)

for cmd in "${primary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        primary_package_manager="$cmd"
        break
    fi
done

if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    echo "${green}Primary Package Manager: $primary_package_manager ${reset}"
fi

# Runs script to install Flatpak
chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
"$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"

# Check for Flatpak
flatpak_installed=0
if command -v flatpak > /dev/null 2>&1; then
    flatpak_installed=1
    echo "${green}Flatpak detected. ${reset}"
fi

# Define the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')
echo "${green}Desktop: $desktop ${reset}"

# Lists of packages
packages=("goverlay")
auto_flatpaks=("io.github.radiolamp.mangojuice")
manual_flatpaks=("org.freedesktop.Platform.VulkanLayer.MangoHud")

# Checks for package manager and installs MangoHud
case "$primary_package_manager" in
    "apt")
        sudo apt-get install -y mangohud
        ;;
    "dnf")
        sudo dnf install -y mangohud
        ;;
    "eopkg")
        sudo eopkg install -y mangohud
        ;;
    "pacman")
        sudo pacman -S --needed --noconfirm mangohud lib32-mangohud
        ;;
    "xbps")
        sudo xbps-install -Sy MangoHud MangoHud-32bit
        ;;
    "zypper")
        sudo zypper in -y mangohud mangohud-32bit
        ;;
esac

# Checks for package manager
if [[ ! "$primary_package_manager" =~ ^(rpm-ostree)$ ]]; then

    # Function for user input
    install_gui() {
        while true; do
            read -r -p "Install GTK or Qt application, or cancel (g/q/c)? " answer

            case "$answer" in
                [Gg])
                    return 0
                    ;;
                [Qt])
                    return 1
                    ;;
                [Cc])
                    exit 1
                    ;;
                *)
                    echo "Enter a 'g','q' or 'c'."
                    ;;
            esac
        done
    }

else
    if [[ "$flatpak_installed" -eq 1 ]]; then
        flatpak install flathub -y "${auto_flatpaks[@]}"
        flatpak install flathub "${manual_flatpaks[@]}"
    fi
fi

# Checks for answer and installs package(s)
if install_gui; then
    flatpak install flathub -y "${auto_flatpaks[@]}"
    flatpak install flathub "${manual_flatpaks[@]}"

else
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
        "rpm-ostree")
            sudo rpm-ostree install "${packages[@]}"
            ;;
    esac

    flatpak install flathub "${manual_flatpaks[@]}"
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/MangoHud"
mkdir -pv "$HOME/Documents/mangohud/logs"

# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud.conf" "$HOME/.config/MangoHud/"

if [ "$host_system" = "laptop" ]; then
    
    # Edits FPS limits
    sed -i 's/fps_limit=160,120,90,60,30,0/fps_limit=60,30,0/' "$HOME/.config/MangoHud/MangoHud.conf"

fi

# Adds output folder for MangoHud logs
echo "output_folder=$HOME/Documents/mangohud/logs" >> "$HOME/.config/MangoHud/MangoHud.conf"

# Prints a conclusive message
echo "${green}MangoHud + MangoJuice/Goverlay is now installed. ${reset}"

