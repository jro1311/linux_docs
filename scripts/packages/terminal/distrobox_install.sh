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

    os="${os,,}"
    os_like="${os_like,,}"

    echo "${green}Distro (ID): $os ${reset}"
    echo "${green}Distro (ID_LIKE): $os_like ${reset}"

    debian_version="0"
    ubuntu_version="0"
    fedora_version="0"
    openmandriva_version="0"
    opensuse_version="0"

    case "$os" in
        "debian")
            debian_version="${VERSION_ID-:0}"
            echo "${green}Version: $debian_version ${reset}"
            ;;
        "ubuntu")
            ubuntu_version="${VERSION_ID-:0}"
            echo "${green}Version: $ubuntu_version ${reset}"
            ;;
        "fedora")
            fedora_version="${VERSION_ID-:0}"
            echo "${green}Version: $fedora_version ${reset}"
            ;;
        "openmandriva")
            openmandriva_version="${VERSION_ID-:0}"
            echo "${green}Version: $openmandriva_version ${reset}"
            ;;
        "opensuse-leap")
            opensuse_version="${VERSION_ID-:0}"
            echo "${green}Version: $opensuse_version ${reset}"
            ;;
        *)
            case "$os_like" in
                "debian")
                    debian_version="${VERSION_ID-:0}"
                    echo "${green}Version: $debian_version ${reset}"
                    ;;
                "ubuntu debian")
                    ubuntu_version="${VERSION_ID-:0}"
                    echo "${green}Version: $ubuntu_version ${reset}"
                    ;;
                "fedora")
                    fedora_version="${VERSION_ID-:0}"
                    echo "${green}Version: $fedora_version ${reset}"
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

if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    echo "${green}Primary Package Manager: $primary_package_manager ${reset}"
fi

if [ "$secondary_package_manager" != "unknown" ]; then
    echo "${green}Secondary Package Manager: $secondary_package_manager ${reset}"
fi

# List of packages
packages=("distrobox" "podman")

# Checks for package manager and installs package(s)
case "$primary_package_manager" in
    "apt")
        sudo apt-get install -y "${packages[@]}"
        ;;
    "dnf")
        sudo dnf install -y "${packages[@]}"
        ;;
    "eopkg")
        sudo eopkg install -y "${packages[@]}"
        ;;
    "pacman")
        sudo pacman -S --needed --noconfirm "${packages[@]}"
        ;;
    "zypper")
        sudo zypper in -y "${packages[@]}"
        ;;
    "rpm-ostree")
        if ! command -v "${packages[@]}" >/dev/null 2>&1; then
            sudo rpm-ostree install "${packages[@]}"
            echo "${yellow}Reboot and run script again to complete. ${reset}"
            exit 0
        fi
        ;;
    *)
        echo "${red}Unsupported package manager. ${reset}"
        exit 1
        ;;
esac

# Creates distrobox container based on operating system
case $os in
    "arch")
        distrobox-create "$os" -i arch:latest
        ;;
    "debian")
        distrobox-create "$os" -i debian:latest
        ;;
    "fedora")
        distrobox-create "$os" -i fedora:latest
        ;;
    "opensuse")
        distrobox-create "$os" -i opensuse:latest
        ;;
    "ubuntu")
        distrobox-create "$os" -i ubuntu:latest
        ;;
    *)
        case "$os_like" in
            "debian")
                distrobox-create "$os" -i debian:latest
                ;;
            "ubuntu debian")
                distrobox-create "$os" -i ubuntu:latest
                ;;
            "fedora")
                distrobox-create "$os" -i fedora:latest
                ;;
            *)
                distrobox-create arch -i arch:latest
                ;;
        esac
esac

# Prints a conclusive message
echo "${green}Distrobox is now installed. ${reset}"

