#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for package
if ! command -v rsync > /dev/null 2>&1; then

    # Define primary package manager
    if command -v apt > /dev/null 2>&1; then
        primary_package_manager="apt"
        echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

    elif command -v dnf > /dev/null 2>&1; then
        primary_package_manager="dnf"
        echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

    elif command -v pacman > /dev/null 2>&1; then
        primary_package_manager="pacman"
        echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

    elif command -v xbps-install > /dev/null 2>&1; then
        primary_package_manager="xbps"
        echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

    elif command -v zypper > /dev/null 2>&1; then
        primary_package_manager="zypper"
        echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

    elif command -v rpm-ostree > /dev/null 2>&1; then
        primary_package_manager="rpm-ostree"
        echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

    else
        primary_package_manager="unknown"
    fi

    # List of packages
    packages=("rsync")

    # Checks for package manager and installs package(s)
    if [ "$primary_package_manager" = "apt" ]; then
        sudo apt-get install -y "${packages[@]}"

    elif [ "$primary_package_manager" = "dnf" ]; then
        sudo dnf install -y "${packages[@]}"

    elif [ "$primary_package_manager" = "pacman" ]; then
        sudo pacman -S --needed --noconfirm "${packages[@]}"

    elif [ "$primary_package_manager" = "xbps" ]; then
        sudo xbps-install -Sy "${packages[@]}"

    elif [ "$primary_package_manager" = "zypper" ]; then
        sudo zypper in -y "${packages[@]}"

    elif [ "$primary_package_manager" = "rpm-ostree" ]; then

        if command -v toolbox > /dev/null 2>&1; then
            toolbox_managers=(apt dnf pacman xbps zypper)

            for toolbox_manager in "${toolbox_managers[@]}"; do
                case "$toolbox_manager" in
                    "apt")
                        if toolbox run command -v apt > /dev/null 2>&1; then
                            toolbox run sudo apt-get install -y "${packages[@]}"
                        fi
                        ;;
                    "dnf")
                        if toolbox run command -v dnf > /dev/null 2>&1; then
                            toolbox run sudo dnf install -y "${packages[@]}"
                        fi
                        ;;
                    "pacman")
                        if toolbox run command -v pacman > /dev/null 2>&1; then
                            toolbox run sudo pacman -S --needed --noconfirm "${packages[@]}"
                        fi
                        ;;
                    "xbps")
                        if toolbox run command -v xbps-install > /dev/null 2>&1; then
                            toolbox run sudo xbps-install -Sy "${packages[@]}"
                        fi
                        ;;
                    "zypper")
                        if toolbox run command -v zypper se > /dev/null 2>&1; then
                            toolbox run sudo zypper in -y "${packages[@]}"
                        fi
                        ;;
                esac
            done

        else
            sudo rpm-ostree install "${packages[@]}"
            echo "${yellow}Reboot and run script again to complete ${reset}"
            exit 0
        fi

    else
        echo "${red}Unsupported package manager${reset}"
        exit 1
    fi
fi

# Prompts the user for input
read -er -p "Enter the path of the source directory: " source

# Expand ~ or $HOME to the full path
source="${source/#~/$HOME}"
source="${source/#\$HOME/$HOME}"

# Checks for directory
if [ ! -d "$source" ]; then
    echo "${red}$source does not exist ${reset}"
    exit 1
fi

# Prints source directory
echo "${green}Source: $source ${reset}"

# Prompts user for input
read -r -p "Press enter to proceed, or ctrl+c to cancel: "

# Flushes all pending write operations on all disks
sync

# Get list of mounted drives
mounted_drives=$(lsblk -o MOUNTPOINT -nr | grep -E '^(/run/media|/media|/mnt)')

# Track if syncs were sucessfully
sync_success=false

# Enables nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Loops through each mounted drive and syncs the directory
for drive in $mounted_drives; do

    # Skips Ventoy drives
    if [[ "$drive" = "/run/media/${USER}/Ventoy"* ]]; then
        echo "${yellow}Skipped Ventoy Drive: $drive ${reset}"
        continue
    fi

    # Skips Ventoy EFI partitions
    if [[ "$drive" = "/run/media/${USER}/VTOYEFI"* ]]; then
        echo "${yellow}Skipped Ventoy Drive: $drive ${reset}"
        continue
    fi

    # Create the destination path
    destination="$drive/"

    # Syncs the source with the destination and checks if it was successful
    if rsync -auhvP --modify-window=1 "$source" "$destination"; then
        echo "${green}Successfully synced with $destination ${reset}"
        sync_success=true
    else
        echo "${red}Failed to sync with $destination ${reset}"
    fi
    
done

# Prints a conclusive message
if [ "$sync_success" = true ]; then
    echo "${green}$source has successfully synced with all mounted drives ${reset}"
else
    echo "${red}$source has failed to sync with all mounted drives ${reset}"
fi
