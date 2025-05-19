#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Source folder to copy
SOURCE_FOLDER=$HOME/Documents/linux_docs

# Check if the source folder exists
if [ ! -d "$SOURCE_FOLDER" ]; then
    echo "Source folder does not exist: $SOURCE_FOLDER"
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

