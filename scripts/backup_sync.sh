#!/bin/bash

# Ensures that scripts exit immediately when any error occurs, and it treats unset variables and pipeline failures as errors
set -euo pipefail

# Source folder to copy
SOURCE_FOLDER=/run/media/linux_backup1

# Check if the source folder exists
if [ ! -d "$SOURCE_FOLDER" ]; then
    echo "Source folder does not exist: $SOURCE_FOLDER"
    exit 1
fi

# Destination folder
DESTINATION=/run/media/linux_backup2

# Syncs the contents of linux_backup1 with linux_backup2, preserving attributes (-a), overwriting only older files (-u), verbose (-v), showing progress (-P)
rsync -auvP "$SOURCE_FOLDER"/* "$DESTINATION"

# Check if the sync was successful
if [ $? -eq 0 ]; then
    echo "Files were successfully synced with $DESTINATION."
else
    echo "Files failed to synced with $DESTINATION."
fi

