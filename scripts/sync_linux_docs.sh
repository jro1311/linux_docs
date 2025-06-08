#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Variables for text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Source directory
source="$HOME/Documents/linux_docs"

# Checks if the source directory exists
if [ ! -d "$source" ]; then
    echo "$source does not exist"
    read -p "Press enter to exit"
    exit 1
fi

# Prints source directory
echo "Source: $source"

# Gets a list of mounted drives (excluding temporary filesystems)
mounted_drives=$(lsblk -o MOUNTPOINT -nr | grep -E '^(/run/media|/media|/mnt)')

# Track if syncs were sucessfully
sync_success=false

# Loops through each mounted drive and syncs the directory
for drive in $mounted_drives; do
    # Skips Ventoy drives
    if [ "$drive" = "/run/media/${USER}/Ventoy" ]; then
        echo "Skipped Ventoy drive: $drive"
        continue
    fi

    # Creates the destination path
    destination="$drive/"

    # Syncs the source with the destination and checks if it was successful
    if rsync -auhv --delete --progress "$source" "$destination"; then
        echo "${green}Successfully synced with $destination${reset}"
        sync_success=true
    else
        echo "${red}Failed to sync with $destination${reset}"
    fi
done

# Prints a conclusive message
if [ "$sync_success" = true ]; then
    echo "${green}$source has successfully synced with all mounted drives"
else
    echo "${red}$source has failed to sync with all mounted drives"
fi
read -p "Press enter to exit"
