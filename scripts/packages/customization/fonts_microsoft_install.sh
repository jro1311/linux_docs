#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Define the operating system and convert it to lowercase
if [ -f /etc/os-release ]; then
    . /etc/os-release
    
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
    
    os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
    os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')
    
    echo "${green}Detected Distro (ID): $os ${reset}"
    echo "${green}Detected Distro (ID_LIKE): $os_like ${reset}"
    
else
    echo "${red}Unable to detect the operating system. ${reset}"
    exit 1
fi

# Define primary package manager
if command -v apt > /dev/null 2>&1; then
    primary_package_manager="apt"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v dnf > /dev/null 2>&1; then
    primary_package_manager="dnf"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

elif command -v eopkg > /dev/null 2>&1; then
    primary_package_manager="eopkg"
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

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then
    sudo apt-get install -y software-properties-common
    
    # Executes commands based on the operating system
    case "$os" in
        "debian")
            # Adds repo(s)
            sudo apt-add-repository -y contrib non-free-firmware
            ;;
        "ubuntu")
            # Adds repo(s)
            sudo add-apt-repository multiverse
            ;;
        *)
            case "$os_like" in
                "debian")
                    # Adds repo(s)
                    sudo apt-add-repository -y contrib non-free-firmware
                    ;;
                "ubuntu debian"|"ubuntu")
                    # Adds repo(s)
                    sudo add-apt-repository multiverse
                    ;;
                *)
                    echo "${red}Unsupported distribution. ${reset}"
                    exit 1
                    ;;
            esac
            ;;
    esac
    
    sudo apt-get install -y fontconfig ttf-mscorefonts-installer

elif [ "$primary_package_manager" = "dnf" ]; then

    if [ "$os" = "openmandriva" ]; then
        echo "${yellow}Manual installation required. ${reset}"
        exit 0
    else 
        sudo dnf install -y cabextract curl fontconfig xorg-x11-font-utils
        sudo dnf install -y https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
    fi

elif [ "$primary_package_manager" = "eopkg" ]; then
    sudo eopkg install -y fonts-installer fontconfig

elif [ "$primary_package_manager" = "pacman" ]; then

    # Checks for AUR package manager
    if [ "$aur_package_manager" != "unknown" ]; then
        "$aur_package_manager" -S ttf-ms-win11-auto
    else
        # Installs package(s)
        sudo pacman -S --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ..
        rm -rf paru
        paru -S ttf-ms-win11-auto
    fi

elif [ "$primary_package_manager" = "zypper" ]; then
    sudo zypper in -y fetchmsttfonts fontconfig

elif [ "$primary_package_manager" = "rpm-ostree" ]; then
    echo "${yellow}Run 'fonts_microsoft_fedora_atomic_install.sh' instead ${reset}"
    exit 0
    
else
    echo "${yellow}Manual installation required. ${reset}"
    exit 0
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/fontconfig"

# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/fontconfig/fonts.conf" "$HOME/.config/fontconfig/"

# Prints a conclusive message
echo "${green}Microsoft fonts are now installed. ${reset}"
