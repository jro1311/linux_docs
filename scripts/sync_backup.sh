#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Prompts the user for input
read -r -p "Enter the path of the source backup drive (default is /run/media/linux_backup1): " source

# Uses default if no input is given
source=${source:-/run/media/linux_backup1}

# Ensures the directory exists
if [ ! -d "$source" ]; then
    echo "Directory $source does not exist. Exiting."
    exit 1
fi

# Prints source directory
echo "Source selected: $source"

# Prompts the user for input
read -r -p "Enter the path of the destination backup drive (default is /run/media/linux_backup2): " destination

# Uses default if no input is given
destination=${destination:-/run/media/linux_backup2}

# Ensures the directory exists
if [ ! -d "$source" ]; then
    echo "$source does not exist"
    exit 1
fi

# Prints destination directory
echo "Destination selected: $destination"

# Syncs the source with the destination and checks if the sync was successful
if rsync -auvP "$source"/* "$destination"; then
    echo "Files were successfully synced with $destination."
else
    echo "Files failed to sync with $destination."
fi

