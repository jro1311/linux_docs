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

# List of packages
packages=("micro")

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then
    sudo apt-get install -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "dnf" ]; then
    sudo dnf install -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "pacman" ]; then
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
elif [ "$primary_package_manager" = "xbps" ]; then
    sudo xbps-install -Sy "${packages[@]}"
    
elif [ "$primary_package_manager" = "zypper" ]; then
    sudo zypper in -y micro-editor
    
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
mkdir -pv "$HOME/.config/micro"

# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/micro/settings.json" "$HOME/.config/micro/"

# Prints a conclusive message
echo "${green}micro is now installed. ${reset}"

