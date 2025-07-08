#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for package manager
if ! command -v apt > /dev/null 2>&1; then
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

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
    echo "${red}Unable to detect the operating system ${reset}"
    exit 1
fi

sudo apt-get install -y software-properties-common

# Executes commands based on the operating system
case "$os" in
    "debian")
        # Adds contrib and non-free repositories
        sudo apt-add-repository -y contrib non-free-firmware
        ;;
    "kubuntu")
        # Adds repo(s)
        sudo add-apt-repository multiverse    
    
        sudo apt-get install -y kubuntu-restricted-addons kubuntu-restricted-extras
        ;;
    "linuxmint")
        # Adds repo(s)
        sudo add-apt-repository multiverse 
        
        sudo apt-get install -y mint-meta-codecs
        ;;
    "lubuntu")
        # Adds repo(s)
        sudo add-apt-repository multiverse
        
        sudo apt-get install -y lubuntu-restricted-addons lubuntu-restricted-extras
        ;;
    "ubuntu")
        # Adds repo(s)
        sudo add-apt-repository multiverse
        
        sudo apt-get install -y ubuntu-restricted-addons ubuntu-restricted-extras
        ;;
    "xubuntu")
        # Adds repo(s)
        sudo add-apt-repository multiverse
        
        sudo apt-get install -y xubuntu-restricted-addons xubuntu-restricted-extras
        ;;
    *)
        case "$os_like" in
            "debian")
                # Adds contrib and non-free repositories
                sudo apt-add-repository -y contrib non-free-firmware
                ;;
            "ubuntu"|"ubuntu debian")
                # Adds repo(s)
                sudo add-apt-repository multiverse

                sudo apt-get install -y ubuntu-restricted-addons ubuntu-restricted-extras
                ;;
            *)
                echo "${red}Unsupported distribution ${reset}"
                exit 1
                ;;
        esac
        ;;
esac

sudo apt-get install -y libavcodec-extra

# Checks for optical drive
if [ -e /dev/sr0 ]; then
    echo "${green}Optical drive detected ${reset}"
    sudo apt-get install -y libdvd-pkg
else
    echo "${yellow}No optical drive detected ${reset}"
fi

# Prints a conclusive message
echo "${green}Multimedia codecs are now installed ${reset}"

