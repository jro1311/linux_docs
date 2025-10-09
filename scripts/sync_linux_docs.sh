#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Source directory
source="$HOME/Documents/linux_docs"

# Checks for directory
if [ ! -d "$source" ]; then
    echo "${red}$source does not exist ${reset}"
    exit 1
fi

# Prints source directory
echo "${green}Source: $source ${reset}"

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
    if rsync -auhvP --modify-window=1 --delete "$source" "$destination"; then
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
