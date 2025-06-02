#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Prompts the user for input
read -p "Enter the source folder path: " SOURCE_FOLDER
SOURCE_FOLDER=$(eval echo "$SOURCE_FOLDER")

# Check if the source folder exists
if [ ! -d "$SOURCE_FOLDER" ]; then
    echo "Error: $SOURCE_FOLDER does not exist"
    exit 1
fi

# Get a list of mounted drives (excluding temporary filesystems)
MOUNTED_DRIVES=$(lsblk -o MOUNTPOINT | grep -E '^(/run/media|/media|/mnt)')

# Flag to track if any copies were made
COPY_SUCCESS=false

# Loop through each mounted drive and copy the folder
for DRIVE in $MOUNTED_DRIVES; do
    # Create the destination path
    DESTINATION="$DRIVE/"

    # Copy the folder to the destination
    cp -ruv "$SOURCE_FOLDER" "$DESTINATION"

    # Check if the copy was successful
    if [ $? -eq 0 ]; then
        echo "Successfully copied to $DESTINATION"
        COPY_SUCCESS=true
    else
        echo "Failed to copy to $DESTINATION"
    fi
done

# Print a conclusive message to end the script
if [ "$COPY_SUCCESS" = true ]; then
    echo "$SOURCE_FOLDER has been successfully copied to all mounted drives."
else
    echo "Failed to copy $SOURCE_FOLDER to all mounted drives."
fi
