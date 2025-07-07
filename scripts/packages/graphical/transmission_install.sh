#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for flatpak and flathub
if ! command -v flatpak > /dev/null 2>&1 || ! flatpak remote-list | grep -q "flathub"; then
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"

# Detect the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Prints the detected desktop
echo "Detected Desktop: $desktop"

# Function for user input
get_answer() {
    while true; do
        read -r -p "Install GTK or Qt version, or cancel (g/q/c)? " answer
        case "$answer" in
            [Gg]* ) return 0;;
            [Qt]* ) return 1;;
            [Cc]* ) exit 1;;
            * ) echo "Enter a 'g','q' or 'c'";;
        esac
    done
}

# Checks for answer
if get_answer; then
    if command -v apt > /dev/null 2>&1; then
        echo "Detected: apt"
        # Installs package(s)
        sudo apt-get install -y transmission-gtk
        
    elif command -v dnf > /dev/null 2>&1; then
        echo "Detected: dnf"
        # Installs package(s)
        sudo dnf install -y transmission-gtk
        
    elif command -v pacman > /dev/null 2>&1; then
        echo "Detected: pacman"
        # Installs package(s)
        sudo pacman -S --needed --noconfirm transmission-gtk
        
    elif command -v xbps-install > /dev/null 2>&1; then
        echo "Detected: xbps"
        # Installs package(s)
        sudo xbps-install -Sy transmission-gtk
        
    elif command -v zypper > /dev/null 2>&1; then
        echo "Detected: zypper"
        # Installs package(s)
        sudo zypper in -y transmission-gtk
        
    elif command -v snap > /dev/null 2>&1; then
        sudo snap install transmission
        
        # Adds package(s) to autostart
        cp -v /var/lib/snap/desktop/applications/transmission*.desktop "$HOME/.config/autostart/"
        
        # Prints a conclusive message
        echo "Transmission is now installed"
        exit 0
        
    elif command -v rpm-ostree > /dev/null 2>&1; then
        echo "Detected: rpm-ostree"
        flatpak install flathub -y com.transmissionbt.Transmission
        
        # Adds package(s) to autostart
        cp -v /var/lib/flatpak/exports/share/applications/com.transmissionbt.Transmission.desktop "$HOME/.config/autostart/"
        
        # Prints a conclusive message
        echo "Transmission is now installed"
        exit 0

    else
        echo "Unsupported package manager"
        exit 1
    fi
else
    if command -v apt > /dev/null 2>&1; then
        echo "Detected: apt"
        # Installs package(s)
        sudo apt-get install -y transmission-qt
        
    elif command -v dnf > /dev/null 2>&1; then
        echo "Detected: dnf"
        # Installs package(s)
        sudo dnf install -y transmission-qt
        
    elif command -v pacman > /dev/null 2>&1; then
        echo "Detected: pacman"
        # Installs package(s)
        sudo pacman -S --needed --noconfirm transmission-qt
        
    elif command -v xbps-install > /dev/null 2>&1; then
        echo "Detected: xbps"
        # Installs package(s)
        sudo xbps-install -Sy transmission-qt
        
    elif command -v zypper > /dev/null 2>&1; then
        echo "Detected: zypper"
        # Installs package(s)
        sudo zypper in -y transmission-qt
        
    elif command -v snap > /dev/null 2>&1; then
        sudo snap install transmission
        
        # Adds package(s) to autostart
        cp -v /var/lib/snap/desktop/applications/transmission*.desktop "$HOME/.config/autostart/"
        
        # Prints a conclusive message
        echo "Transmission is now installed"
        exit 0
        
    elif command -v rpm-ostree > /dev/null 2>&1; then
        echo "Detected: rpm-ostree"
        flatpak install flathub -y com.transmissionbt.Transmission
        
        # Adds package(s) to autostart
        cp -v /var/lib/flatpak/exports/share/applications/com.transmissionbt.Transmission.desktop "$HOME/.config/autostart/"
        
        # Prints a conclusive message
        echo "Transmission is now installed"
        exit 0
        
    else
        echo "Unsupported package manager"
        exit 1
    fi
fi

# Adds package(s) to autostart
cp -v /usr/share/applications/transmission*.desktop "$HOME/.config/autostart/"

# Prints a conclusive message
echo "${green}Transmission is now installed ${reset}"
