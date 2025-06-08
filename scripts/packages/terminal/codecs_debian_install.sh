#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s)
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y software-properties-common

# Detects the operating system and stores it in a variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "Unable to detect the operating system"
    read -p "Press enter to exit"
    exit 1
fi

# Converts the variable into lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Prints the detected operating system
echo "Detected: $os"

# Installs packages based on the detected operating system
case "$os" in
    "debian")
        # Adds contrib and non-free repositories
        sudo apt-add-repository -y contrib non-free-firmware
        ;;
    "kubuntu")
        # Adds repo(s)
        sudo add-apt-repository multiverse    
    
        # Installs package(s)
        sudo apt-get install -y kubuntu-restricted-addons kubuntu-restricted-extras
        ;;
    "linuxmint")
        # Adds repo(s)
        sudo add-apt-repository multiverse 
        
        # Installs package(s)
        sudo apt-get install -y mint-meta-codecs
        ;;
    "lubuntu")
        # Adds repo(s)
        sudo add-apt-repository multiverse
        
        # Installs package(s)
        sudo apt-get install -y lubuntu-restricted-addons lubuntu-restricted-extras
        ;;
    "ubuntu")
        # Adds repo(s)
        sudo add-apt-repository multiverse
        
        # Installs package(s)
        sudo apt-get install -y ubuntu-restricted-addons ubuntu-restricted-extras
        ;;
    "xubuntu")
        # Adds repo(s)
        sudo add-apt-repository multiverse
        
        # Installs package(s)
        sudo apt-get install -y xubuntu-restricted-addons xubuntu-restricted-extras
        ;;
    *)
        case "$os_like" in
            "debian")
                # Adds contrib and non-free repositories
                sudo apt-add-repository -y contrib non-free-firmware
                ;;
            "ubuntu debian")
                # Adds repo(s)
                sudo add-apt-repository multiverse

                # Installs package(s)
                sudo apt-get install -y ubuntu-restricted-addons ubuntu-restricted-extras
                ;;
            *)
                echo "Unsupported distribution"
                read -p "Press enter to exit"
                exit 1
                ;;
        esac
        ;;
esac

# Installs package(s)
sudo apt-get install -y libavcodec-extra

# Checks for optical drive
if [ -e /dev/sr0 ]; then
    echo "Optical drive detected"
    # Installs package(s)
    sudo apt-get install -y libdvd-pkg
else
    echo "No optical drive detected"
fi

# Prints a conclusive message
echo "Multimedia codecs are now installed"
read -p "Press enter to exit"
