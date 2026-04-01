#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
if command -v tput &>/dev/null; then
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    yellow=$(tput setaf 3)
    blue=$(tput setaf 4)
    reset=$(tput sgr0)
else
    # Fallback for systems without tput
    red=$'\033[31m'
    green=$'\033[32m'
    yellow=$'\033[33m'
    blue=$'\033[34m'
    reset=$'\033[0m'
fi

# Define the operating system and convert it to lowercase
if [ -f /etc/os-release ]; then
    source /etc/os-release

    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"

    os="${os,,}"
    os_like="${os_like,,}"

    if [ "$os_like" != "$os" ]; then
        echo "${green}Base Distro(s):${reset} $os_like"
    fi

    echo "${green}Distro:${reset} $os"

    debian_version="0"
    ubuntu_version="0"
    linuxmint_version="0"
    fedora_version="0"
    openmandriva_version="0"
    opensuse_version="0"

    case "$os" in
        "debian")
            debian_version="${VERSION_ID:-0}"
            echo "${green}Distro Version:${reset} $debian_version"
            ;;
        "ubuntu")
            ubuntu_version="${VERSION_ID:-0}"
            echo "${green}Distro Version:${reset} $ubuntu_version"
            ;;
        "linuxmint")
            linuxmint_version="${VERSION_ID:-0}"
            echo "${green}Distro Version:${reset} $linuxmint_version"
            ;;
        "fedora")
            fedora_version="${VERSION_ID:-0}"
            echo "${green}Distro Version:${reset} $fedora_version"
            ;;
        "openmandriva")
            openmandriva_version="${VERSION_ID:-0}"
            echo "${green}Distro Version:${reset} $openmandriva_version"
            ;;
        "opensuse-leap")
            opensuse_version="${VERSION_ID:-0}"
            echo "${green}Distro Version:${reset} $opensuse_version"
            ;;
        *)
            case "$os_like" in
                "debian")
                    debian_version="${VERSION_ID:-0}"
                    echo "${green}Base Version:${reset} $debian_version"
                    ;;
                "ubuntu debian")
                    ubuntu_version="${VERSION_ID:-0}"
                    echo "${green}Base Version:${reset} $ubuntu_version"
                    ;;
                "fedora")
                    fedora_version="${VERSION_ID:-0}"
                    echo "${green}Base Version:${reset} $fedora_version"
                    ;;
            esac
            ;;
    esac
else
    echo "${red}Unable to detect the operating system.${reset}"
    exit 1
fi

# List of packages
packages=(
    "package1"
    "package2"
)

aur_packages=(
    "aur-package1"
    "aur-package2"
)

flatpaks=(
    "flatpak1"
    "flatpak2"
)

# Executes commands based on the operating system
case "$os" in
    "arch")
        sudo pacman -S --needed --noconfirm "${packages[@]}"
        ;;
    "debian"|"ubuntu")
        sudo apt-get install -y "${packages[@]}"
        ;;
    "fedora"|"openmandriva")
        sudo dnf install -y "${packages[@]}"
        ;;
    "opensuse"*)
        sudo zypper in -y "${packages[@]}"
        ;;
    "solus")
        sudo eopkg install -y "${packages[@]}"
        ;;
    "void")
        sudo xbps-install -Sy "${packages[@]}"
        ;;
    *)
        case "$os_like" in
            "arch")
                sudo pacman -S --needed --noconfirm "${packages[@]}"
                ;;
            "debian"|"ubuntu debian")
                sudo apt-get install -y "${packages[@]}"
                ;;
            "fedora")
                sudo dnf install -y "${packages[@]}"
                ;;
            "opensuse suse")
                sudo zypper in -y "${packages[@]}"
                ;;
            "solus")
                sudo eopkg install -y "${packages[@]}"
                ;;
            "void")
                sudo xbps-install -Sy "${packages[@]}"
                ;;
            *)
                echo "${red}Unsupported distribution.${reset}"
                exit 1
                ;;
        esac
        ;;
esac
