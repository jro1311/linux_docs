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

# Define the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')
echo "${green}Detected Desktop: $desktop ${reset}"

# Executes commands based on the operating system
case "$os" in
    "debian")
        # Converts old sources.list format into modern debian.sources format
        sudo apt modernize-sources -y

        # Checks for contrib repository
        if ! grep -Fq "contrib" /etc/apt/sources.list.d/debian.sources; then

            # Adds repo(s)
            sudo sed -i '/Components:/ s/$/ contrib/' /etc/apt/sources.list.d/debian.sources
            sudo apt-get update
        fi
        ;;
    "linuxmint")
        sudo apt-get install -y software-properties-common
        sudo add-apt-repository multiverse
        sudo apt-get install -y mint-meta-codecs
        ;;
    "ubuntu")
        sudo apt-get install -y software-properties-common
        sudo add-apt-repository multiverse
        sudo apt-get install -y ubuntu-restricted-addons ubuntu-restricted-extras
        ;;
    *)
        case "$os_like" in
            "debian")
                # Converts old sources.list format into modern debian.sources format
                sudo apt modernize-sources -y

                # Checks for contrib repository
                if ! grep -Fq "contrib" /etc/apt/sources.list.d/debian.sources; then

                    # Adds repo(s)
                    sudo sed -i '/Components:/ s/$/ contrib/' /etc/apt/sources.list.d/debian.sources
                    sudo apt-get update
                fi
                ;;
            "ubuntu"|"ubuntu debian")
                sudo apt-get install -y software-properties-common
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

# Checks for Ubuntu
if [ "$os" = "ubuntu" ]; then
    case "$desktop" in
        "kde"|"plasma")
        sudo apt-get install -y kubuntu-restricted-addons kubuntu-restricted-extras
        ;;
        "lxqt")
        sudo apt-get install -y lubuntu-restricted-addons lubuntu-restricted-extras
        ;;
        "xfce")
        sudo apt-get install -y xubuntu-restricted-addons xubuntu-restricted-extras
        ;;
    esac
fi

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

