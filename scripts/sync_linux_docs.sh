#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Source directory
source="$HOME"/Documents/linux_docs

# Checks if the source directory exists
if [ ! -d "$source" ]; then
    echo "Source directory does not exist: $source"
    exit 1
fi

# Prints source directory
echo "Source selected: $source"

# Gets a list of mounted drives (excluding temporary filesystems)
mounted_drives=$(lsblk -o MOUNTPOINT -nr | grep -E '^(/run/media|/media|/mnt)')

# Flags to track if any copies were made
copy_success=false

# Loops through each mounted drive and copy the directory
for drive in $mounted_drives; do
    # Skips Ventoy drives
    if [ "$drive" = "/run/media/${USER}/Ventoy" ]; then
        echo "Skipped Ventoy drive: $drive"
        continue
    fi

    # Creates the destination path
    destination="$drive/"

    # Copies from source to destination and checks if the copy was successful
    if cp -ruv "$source" "$destination"; then
        echo "Successfully copied to $destination"
        copy_success=true
    else
        echo "Failed to copy to $destination"
    fi
done

# Prints a conclusive message to end the script
if [ "$copy_success" = true ]; then
    echo "$source has been successfully copied to all mounted drives."
else
    echo "Failed to copy $source to all mounted drives."
fi

