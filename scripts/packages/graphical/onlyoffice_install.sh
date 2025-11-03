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

# Define AUR package manager
if command -v paru > /dev/null 2>&1; then
    aur_package_manager="paru"
    echo "Detected Package Manger: $aur_package_manager"

elif command -v yay > /dev/null 2>&1; then
    aur_package_manager="yay"
    echo "Detected Package Manger: $aur_package_manager"
    
else
    aur_package_manager="unknown"
fi

# List of packages
aur_packages=("onlyoffice-bin")
flatpaks=("org.onlyoffice.desktopeditors")
snaps=("onlyoffice-desktopeditors")

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then
    wget -O "$HOME/Downloads/onlyoffice.deb" "https://github.com/ONLYOFFICE/DesktopEditors/releases/latest/download/onlyoffice-desktopeditors_amd64.deb"
    sudo apt-get install -y "$HOME/Downloads/onlyoffice.deb"
    rm -v "$HOME/Downloads/onlyoffice.deb"

elif [ "$primary_package_manager" = "dnf" ]; then
    wget -O "$HOME/Downloads/onlyoffice.rpm" "https://github.com/ONLYOFFICE/DesktopEditors/releases/latest/download/onlyoffice-desktopeditors.x86_64.rpm"
    sudo dnf install -y "$HOME/Downloads/onlyoffice.rpm"
    rm -v "$HOME/Downloads/onlyoffice.rpm"

elif [ "$primary_package_manager" = "pacman" ]; then
    
    # Checks for Chaotic AUR
    if ! grep -Fq "chaotic" /etc/pacman.conf; then
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
        sudo tee -a /etc/pacman.conf <<-'EOF'
        [chaotic-aur]
            Include = /etc/pacman.d/chaotic-mirrorlist

EOF
    fi
    
    # Checks for AUR helper
    if [ "$aur_package_manager" != "unknown" ]; then
        "$aur_package_manager" -S "${aur_packages[@]}"
    else
        sudo pacman -S --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ..
        rm -rf paru
        paru -S "${aur_packages[@]}"
    fi

elif [ "$secondary_package_manager" = "flatpak" ]; then
    flatpak install flathub -y "${flatpaks[@]}"

elif [ "$secondary_package_manager" = "snap" ]; then
    sudo snap install "${snaps[@]}"
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Prints a conclusive message
echo "${green}OnlyOffice is now installed. ${reset}"


