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

ask_for_confirmation() {
    local prompt="$1"
    local answer

    while true; do
        read -r -p "$prompt [Y/n]: " answer
        answer="${answer:-y}"

        case "$answer" in
            [Yy]) return 0 ;;
            [Nn]) return 1 ;;
            *) echo "Enter a 'y' or 'n'." ;;
        esac
    done
}

# Calls function
if ask_for_confirmation "Create a distrobox container now?"; then

    read -r -p "Enter an image to install [options: arch/debian/fedora/opensuse/ubuntu/void]: " image

    # Convert image to lowercase
    image=$(echo "$image" | tr '[:upper:]' '[:lower:]')
    echo "${green}Selected Image: $image ${reset}"

    case "$image" in
        "arch")
            distrobox create -i quay.io/toolbx/arch-toolbox:latest
            ;;
        "debian")
            distrobox create -i quay.io/toolbx-images/debian-toolbox:latest
            ;;
        "fedora")
            distrobox create -i quay.io/fedora/fedora:rawhide
            ;;
        "opensuse")
            distrobox create -i registry.opensuse.org/opensuse/distrobox:latest
            ;;
        "ubuntu")
            distrobox create -i quay.io/toolbx/ubuntu-toolbox:latest
            ;;
        "void")
            distrobox create -i ghcr.io/void-linux/void-glibc-full:latest
            ;;
        *)
            echo "${red}Unsupported image. ${reset}"
            exit 1
            ;;
    esac

fi

# Prints a conclusive message
echo "${green}Distrobox is now installed. ${reset}"

