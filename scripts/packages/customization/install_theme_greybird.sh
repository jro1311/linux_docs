#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
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

# Define package managers
primary_package_manager="unknown"
secondary_package_manager="unknown"

primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)
secondary_package_managers=(nala paru yay)

for cmd in "${primary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        primary_package_manager="$cmd"
        break
    fi
done

for cmd in "${secondary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        secondary_package_manager="$cmd"
        break
    fi
done

# Normalizes xbps-install to xbps
if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    echo "${green}Primary Package Manager: $primary_package_manager ${reset}"
fi

if [ "$secondary_package_manager" != "unknown" ]; then
    echo "${green}Secondary Package Manager: $secondary_package_manager ${reset}"
fi

# Checks for package manager and installs package(s)
case "$primary_package_manager" in
    "apt")
        sudo apt-get install -y greybird-gtk-theme
        ;;
    "dnf")
        if [ "$os" = "openmandriva" ]; then
            echo "${yellow}Manual installation required. ${reset}"
            echo "${yellow}Go to https://github.com/shimmerproject/Greybird/ ${reset}"
            exit 0
        else
            sudo dnf install -y greybird-dark-theme greybird-light-theme
        fi
        ;;
    "pacman")
        if [[ "$secondary_package_manager" =~ ^(paru|yay)$ ]]; then
            "$secondary_package_manager" -S --needed --noconfirm xfce-theme-greybird
        else
            sudo pacman -S --needed --noconfirm base-devel git
            git clone https://aur.archlinux.org/paru.git
            cd paru
            makepkg -si --noconfirm
            cd ..
            rm -rf paru
            paru -S --needed --noconfirm xfce-theme-greybird
        fi
        ;;
    xbps)
        sudo xbps-install -Sy greybird-themes
        ;;
    "zypper")
        sudo zypper in -y metatheme-greybird-common
        ;;
    "rpm-ostree")
        sudo rpm-ostree install greybird-dark-theme greybird-light-theme
        ;;
    *)
        echo "${yellow}Manual installation required. ${reset}"
        echo "${yellow}Go to https://github.com/shimmerproject/Greybird/ ${reset}"
        exit 0
        ;;
esac

# Prints a conclusive message
echo "${green}Greybird theme is now installed. ${reset}"

