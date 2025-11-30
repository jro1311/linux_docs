#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

packages=("rsync")
if ! command -v rsync >/dev/null 2>&1; then

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
fi

echo "${yellow}Note: /path/to/directory != /path/to/directory/ ${reset}"
read -er -p "Enter the path of the source backup drive (default: /run/media/linux_backup1/): " source_dir

# Define source directory
source_dir=${source_dir:-/run/media/linux_backup1/}

# Validates directory
if [ ! -d "$source_dir" ]; then
    echo "${red}$source_dir does not exist ${reset}"
    exit 1
fi

echo "${green}Source: $source_dir ${reset}"
read -er -p "Enter the path of the destination backup drive (default: /run/media/linux_backup2): " destination_dir

# Define destination directory
destination_dir=${destination_dir:-/run/media/linux_backup2}

# Validates directory
if [ ! -d "$destination_dir" ]; then
    echo "${red}$destination_dir does not exist. ${reset}"
    exit 1
fi

echo "${green}Destination: $destination_dir ${reset}"

# Flushes all pending write operations on all disks
sync

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

if ask_for_confirmation "Run a dry run first?"; then
    rsync -auhvP --dry-run --exclude='lost+found' --modify-window=1 "$source_dir" "$destination_dir"
fi

read -r -p "Press enter to proceed, or ctrl+c to cancel: "

# Syncs the source with the destination and checks if it was successful
if rsync -auhvP --exclude='lost+found' --modify-window=1 "$source_dir" "$destination_dir"; then
    echo "${green}Success: '$source_dir' synced with '$destination_dir' ${reset}"
else
    echo "${red}Error: '$source_dir' failed to sync with '$destination_dir' ${reset}"
    exit 1
fi

