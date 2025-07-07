#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Detect the operating system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "${red}Unable to detect the operating system ${reset}"
    exit 1
fi

# Convert operating system to lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Detect main package manager
if command -v apt > /dev/null 2>&1; then
    main_package_manager="apt"
     
elif command -v dnf > /dev/null 2>&1; then
    main_package_manager="dnf"
    
elif command -v pacman > /dev/null 2>&1; then
    main_package_manager="pacman"
    
elif command -v xbps-install > /dev/null 2>&1; then
    main_package_manager="xbps"
    
elif command -v zypper > /dev/null 2>&1; then
    main_package_manager="zypper"

elif command -v rpm-ostree > /dev/null 2>&1; then
    main_package_manager="rpm-ostree"

else
    main_package_manager="unknown"
fi

# Detect AUR package manager
if command -v paru > /dev/null 2>&1; then
    aur_package_manager="paru"

elif command -v yay > /dev/null 2>&1; then
    aur_package_manager="yay"
    
else
    aur_package_manager="unknown"
fi

# Checks for main package manager and installs package(s)
if [ "$main_package_manager" = "apt" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo apt-get install -y software-properties-common
    
    # Executes commands based on the operating system
    case "$os" in
        "debian")
            echo "${green}Detected Distro (ID): $os ${reset}"
            # Adds repo(s)
            sudo apt-add-repository -y contrib non-free-firmware
            ;;
        "ubuntu")
            echo "${green}Detected Distro (ID): $os ${reset}"
            # Adds repo(s)
            sudo add-apt-repository multiverse
            ;;
        *)
            case "$os_like" in
                "debian")
                    echo "${green}Detected Distro (ID_LIKE): $os ${reset}"
                    # Adds repo(s)
                    sudo apt-add-repository -y contrib non-free-firmware
                    ;;
                "ubuntu debian"|"ubuntu")
                    echo "${green}Detected Distro (ID_LIKE): $os ${reset}"
                    # Adds repo(s)
                    sudo add-apt-repository multiverse
                    ;;
                *)
                    echo "Unsupported distribution"
                    exit 1
                    ;;
            esac
            ;;
    esac
    
    sudo apt-get install -y fontconfig ttf-mscorefonts-installer

elif [ "$main_package_manager" = "dnf" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    if [ "$os" = "openmandriva" ]; then
        echo "${green}Detected Distro (ID): $os ${reset}"
        echo "${yellow}Manual installation required ${reset}"
        exit 0
    else 
        sudo dnf install -y cabextract curl fontconfig xorg-x11-font-utils
        sudo dnf install -y https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
    fi

elif [ "$main_package_manager" = "pacman" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    # Checks for AUR helper
    if [ "$aur_package_manager" != "unknown" ]; then
        echo "${green}Detected Package Manager: $aur_package_manager ${reset}"
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

elif [ "$main_package_manager" = "xbps" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    echo "${yellow}Manual installation required ${reset}"
    exit 0

elif [ "$main_package_manager" = "zypper" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo zypper in -y fetchmsttfonts fontconfig
    
elif [ "$main_package_manager" = "rpm-ostree" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    echo "${yellow}Manual installation required ${reset}"
    exit 0
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/fontconfig"

# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/fonts.conf" "$HOME/.config/fontconfig/"

# Prints a conclusive message
echo "${green}Microsoft fonts is now installed ${reset}"
