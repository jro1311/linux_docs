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
packages=("nano")
aur_packages=("nano-syntax-highlighting")

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then
    sudo apt-get install -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "dnf" ]; then
    sudo dnf install -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "pacman" ]; then
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
    # Checks for AUR package manager
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
    
elif [ "$primary_package_manager" = "xbps" ]; then
    sudo xbps-install -Sy "${packages[@]}"
    
elif [ "$primary_package_manager" = "zypper" ]; then
    sudo zypper in -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "rpm-ostree" ]; then
    
    if command -v toolbox > /dev/null 2>&1; then
        toolbox_managers=(apt dnf pacman xbps zypper)

        for toolbox_manager in "${toolbox_managers[@]}"; do
            case "$toolbox_manager" in
                "apt")
                    if toolbox run command -v apt > /dev/null 2>&1; then
                        toolbox run sudo apt-get install -y "${packages[@]}"
                    fi
                    ;;
                "dnf")
                    if toolbox run command -v dnf > /dev/null 2>&1; then
                        toolbox run sudo dnf install -y "${packages[@]}"
                    fi
                    ;;
                "pacman")
                    if toolbox run command -v pacman > /dev/null 2>&1; then
                        toolbox run sudo pacman -S --needed --noconfirm "${packages[@]}"
                    fi
                    ;;
                "xbps")
                    if toolbox run command -v xbps-install > /dev/null 2>&1; then
                        toolbox run sudo xbps-install -Sy "${packages[@]}"
                    fi
                    ;;
                "zypper")
                    if toolbox run command -v zypper se > /dev/null 2>&1; then
                        toolbox run sudo zypper in -y "${packages[@]}"
                    fi
                    ;;
            esac
        done

    else
        sudo rpm-ostree install "${packages[@]}"
    fi
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/nano"

# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/nanorc" "$HOME/.config/nano/"
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/nanorc" /etc/nanorc

# Prints a conclusive message
echo "${green}nano is now installed. ${reset}"

