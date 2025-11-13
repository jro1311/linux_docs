#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Define the operating system and convert it to lowercase
if [ -f /etc/os-release ]; then
    . /etc/os-release

    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"

    os="${os,,}"
    os_like="${os_like,,}"

    if [ "$os_like" != "$os" ]; then
        echo "${green}Base Distro(s): $os_like ${reset}"
    fi

    echo "${green}Distro: $os ${reset}"

    debian_version="0"
    ubuntu_version="0"
    linuxmint_version="0"
    fedora_version="0"
    openmandriva_version="0"
    opensuse_version="0"

    case "$os" in
        "debian")
            debian_version="${VERSION_ID:-0}"
            echo "${green}Distro Version: $debian_version ${reset}"
            ;;
        "ubuntu")
            ubuntu_version="${VERSION_ID:-0}"
            echo "${green}Distro Version: $ubuntu_version ${reset}"
            ;;
        "linuxmint")
            linuxmint_version="${VERSION_ID:-0}"
            echo "${green}Distro Version: $linuxmint_version ${reset}"
            ;;
        "fedora")
            fedora_version="${VERSION_ID:-0}"
            echo "${green}Distro Version: $fedora_version ${reset}"
            ;;
        "openmandriva")
            openmandriva_version="${VERSION_ID:-0}"
            echo "${green}Distro Version: $openmandriva_version ${reset}"
            ;;
        "opensuse-leap")
            opensuse_version="${VERSION_ID:-0}"
            echo "${green}Distro Version: $opensuse_version ${reset}"
            ;;
        *)
            case "$os_like" in
                "debian")
                    debian_version="${VERSION_ID:-0}"
                    echo "${green}Base Version: $debian_version ${reset}"
                    ;;
                "ubuntu debian")
                    ubuntu_version="${VERSION_ID:-0}"
                    echo "${green}Base Version: $ubuntu_version ${reset}"
                    ;;
                "fedora")
                    fedora_version="${VERSION_ID:-0}"
                    echo "${green}Base Version: $fedora_version ${reset}"
                    ;;
            esac
            ;;
    esac
else
    echo "${red}Unable to detect the operating system. ${reset}"
    exit 1
fi

# Adds Debian backports repository
case "$os" in
    "debian")
        # Converts old sources.list format into modern debian.sources format
        sudo apt modernize-sources -y

        if ! [ -f /etc/apt/sources.list.d/debian_backports.sources ]; then

            sudo cp -v "$HOME/Documents/linux_docs/configs/system/debian_backports.sources" /etc/apt/sources.list.d/
            sudo sed -i "/Suites:/ s/version-backports/$(lsb_release -cs)-backports/" /etc/apt/sources.list.d/debian_backports.sources
            sudo apt-get update

        fi
        ;;
    "ubuntu")
        echo "${red}Unsupported operating system. ${reset}"
        exit 1
        ;;
    *)
        case "$os_like" in
            "debian")
                # Converts old sources.list format into modern debian.sources format
                sudo apt modernize-sources -y

                if [ ! -f /etc/apt/sources.list.d/debian_backports.sources ]; then

                    sudo cp -v "$HOME/Documents/linux_docs/configs/system/debian_backports.sources" /etc/apt/sources.list.d/
                    sudo sed -i "/Suites:/ s/version-backports/$(lsb_release -cs)-backports/" /etc/apt/sources.list.d/debian_backports.sources
                    sudo apt-get update

                fi
                ;;
            *)
                echo "${red}Unsupported operating system. ${reset}"
                exit 1
        esac
    ;;
esac

# Prints a conclusive message
echo "${green}Enabled: Debian backports repository ${reset}"
