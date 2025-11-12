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
packages=("toolbox" "podman")

# Checks for package manager and installs package(s)
case "$primary_package_manager" in
    "dnf")
        sudo dnf install -y "${packages[@]}"
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

# Creates toolbox container based on operating system
case $os in
    "fedora")
        toolbox create --distro fedora --release "$fedora_version"
        ;;
esac

# Prints a conclusive message
echo "${green}Toolbox is now installed. ${reset}"
