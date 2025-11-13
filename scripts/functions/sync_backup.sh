#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# List of packages
packages=("rsync")

# Checks for package
if ! command -v rsync > /dev/null 2>&1; then

    # Define primary package manager
    primary_package_manager="unknown"
    primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)

    for cmd in "${primary_package_managers[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            primary_package_manager="$cmd"
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

    # Checks for package manager and installs package(s)
    case $primary_package_manager in
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
        "xbps")
            sudo xbps-install -Sy "${packages[@]}"
            ;;
        "zypper")
            sudo zypper in -y "${packages[@]}"
            ;;
        "rpm-ostree")
            sudo rpm-ostree install "${packages[@]}"
            echo "${yellow}Reboot and run script again to complete. ${reset}"
            exit 0
            ;;
        *)
            echo "${red}Unsupported package manager. ${reset}"
            exit 1
            ;;
    esac
fi

# Prompts the user for input
read -er -p "Enter the path of the source backup drive (default is /run/media/linux_backup1): " source

# Use default if no input is given
source=${source:-/run/media/linux_backup1}

# Validate directory
if [ ! -d "$source" ]; then
    echo "${red}$source does not exist ${reset}"
    exit 1
fi

# Prints source directory
echo "${green}Source: $source ${reset}"

# Prompts the user for input
read -er -p "Enter the path of the destination backup drive (default is /run/media/linux_backup2): " destination

# Use default if no input is given
destination=${destination:-/run/media/linux_backup2}

# Validate directory
if [ ! -d "$destination" ]; then
    echo "${red}$destination does not exist. ${reset}"
    exit 1
fi

# Prints destination directory
echo "${green}Destination: $destination ${reset}"

# Prompts user to continue
read -r -p "Press enter to proceed, or ctrl+c to cancel: "

# Flushes all pending write operations on all disks
sync

# Syncs the source with the destination and checks if it was successful
if rsync -auhvP --exclude='lost+found' --modify-window=1 "$source"/* "$destination"; then
    echo "${green}Success: '$source' synced with '$destination' ${reset}"
else
    echo "${red}Error: '$source' failed to sync with '$destination' ${reset}"
fi

