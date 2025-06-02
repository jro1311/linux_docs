#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Prompts the user for input
read -r -p "Enter the source directory path: " source
source=$(eval echo "$source")

# Check if the source directory exists
if [ ! -d "$source" ]; then
    echo "Error: $source does not exist"
    exit 1
fi

# Get a list of mounted drives (excluding temporary filesystems)
mounted_drives=$(lsblk -o mountpoint | grep -E '^(/run/media|/media|/mnt)')

# Flag to track if any copies were made
copy_success=false

# Loop through each mounted drive and copy the directory
for drive in $mounted_drives; do
    # Create the destination path
    destination="$drive/"

    # Copy the directory to the destination
    cp -ruv "$source" "$destination"

    # Check if the copy was successful
    if cp -ruv "$source" "$destination"; then
        echo "Successfully copied to $destination"
        copy_success=true
    else
        echo "Failed to copy to $destination"
    fi
done

# Print a conclusive message to end the script
if [ "$copy_success" = true ]; then
    echo "$source has been successfully copied to all mounted drives."
else
    echo "Failed to copy $source to all mounted drives."
fi
