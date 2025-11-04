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
    
elif command -v snap > /dev/null 2>&1; then
    secondary_package_manager="snap"
    echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
    
else
    secondary_package_manager="unknown"
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"

# Define the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')
echo "${green}Detected Desktop: $desktop ${reset}"

# Checks for package manager
if [ "$primary_package_manager" != "rpm-ostree" ]; then

    # Function for user input
    get_answer() {
        while true; do
            read -r -p "Install GTK or Qt version, or cancel (g/q/c)? " answer

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
                    echo "Enter a 'g','q' or 'c'"
                    ;;
            esac

        done
    }
fi

# List of packages
gtk_packages=("transmission-gtk")
qt_packages=("transmission-qt")
flatpaks=("com.transmissionbt.Transmission")
snaps=("transmission")

# Checks for answer
if get_answer; then
    # Checks for package manager and installs package(s)
    if [ "$primary_package_manager" = "apt" ]; then
        sudo apt-get install -y "${gtk_packages[@]}"

    elif [ "$primary_package_manager" = "dnf" ]; then
        sudo dnf install -y "${gtk_packages[@]}"

    elif [ "$primary_package_manager" = "pacman" ]; then
        sudo pacman -S --needed --noconfirm "${gtk_packages[@]}"
    
    elif [ "$primary_package_manager" = "xbps" ]; then
        sudo xbps-install -Sy "${gtk_packages[@]}"
        
    elif [ "$primary_package_manager" = "zypper" ]; then
        sudo zypper in -y "${gtk_packages[@]}"

    elif [ "$secondary_package_manager" = "flatpak" ]; then
        flatpak install flathub -y "${flatpaks[@]}"
        
    elif [ "$secondary_package_manager" = "snap" ]; then
        sudo snap install "${snaps[@]}"
        
    elif [ "$primary_package_manager" = "rpm-ostree" ]; then
        sudo rpm-ostree install "${gtk_packages[@]}"
    
    else
        echo "${red}Unsupported package manager ${reset}"
        exit 1
    fi
else
    # Checks for package manager and installs package(s)
    if [ "$primary_package_manager" = "apt" ]; then
        sudo apt-get install -y "${qt_packages[@]}"

    elif [ "$primary_package_manager" = "dnf" ]; then
        sudo dnf install -y "${qt_packages[@]}"
        
    elif [ "$primary_package_manager" = "pacman" ]; then
        sudo pacman -S --needed --noconfirm "${qt_packages[@]}"
        
    elif [ "$primary_package_manager" = "xbps" ]; then
        sudo xbps-install -Sy "${qt_packages[@]}"
        
    elif [ "$primary_package_manager" = "zypper" ]; then
        sudo zypper in -y "${qt_packages[@]}"
        
    elif [ "$secondary_package_manager" = "flatpak" ]; then
        flatpak install flathub -y "${flatpaks[@]}"
        
    elif [ "$secondary_package_manager" = "snap" ]; then
        sudo snap install "${snaps[@]}"
        
    elif [ "$primary_package_manager" = "rpm-ostree" ]; then
        sudo rpm-ostree install "${qt_packages[@]}"
    
    else
        echo "${red}Unsupported package manager ${reset}"
        exit 1
    fi
fi

# Function for user input
get_answer() {
    while true; do
        read -r -p "Add Transmission to autostart? [Y/n]: " answer
        answer="${answer:-y}"

        case "$answer" in
            [Yy])
                return 0
                ;;
            [Nn])
                return 1
                ;;
            *)
                echo "Enter a 'y' or 'n'"
                ;;
        esac

    done
}

# Checks for answer
if get_answer; then

    # Adds package(s) to autostart
    cp -v "$HOME/Documents/linux_docs/configs/packages/transmission.desktop" "$HOME/.config/autostart/"

    if command -v transmission-gtk > /dev/null 2>&1; then
        echo "Exec=transmission-gtk --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"
    
    elif command -v transmission-qt > /dev/null 2>&1; then
        echo "Exec=transmission-qt --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"
    
    elif command -v flatpak > /dev/null 2>&1 && flatpak list | grep -Fq "com.transmissionbt.Transmission"; then
        echo "Exec=flatpak run com.transmissionbt.Transmission --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"
        
    elif command -v snap > /dev/null 2>&1 && snap list | grep -Fq "transmission"; then
        echo "Exec=snap run transmission --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"
    fi
    
fi

# Prints a conclusive message
echo "${green}Transmission is now installed. ${reset}"
