#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Source directory
source=/run/media/linux_backup1

# Check if the source directory exists
if [ ! -d "$source" ]; then
    echo "Source directory does not exist: $source"
    exit 1
fi

# Destination directory
destination=/run/media/linux_backup2

# Syncs the contents of linux_backup1 with linux_backup2, preserving attributes (-a), overwriting only older files (-u), verbose (-v), showing progress (-P)
rsync -auvP "$source"/* "$destination"

# Check if the sync was successful
if rsync -auvP "$source"/* "$destination"; then
    echo "Files were successfully synced with $destination."
else
    echo "Files failed to sync with $destination."
fi

