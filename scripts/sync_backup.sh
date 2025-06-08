#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Variables for text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)

# Prompts the user for input
read -r -p "Enter the path of the source backup drive (default is /run/media/linux_backup1): " source

# Uses default if no input is given
source=${source:-/run/media/linux_backup1}

# Ensures the directory exists
if [ ! -d "$source" ]; then
    echo "$source does not exist"
    read -p "Press enter to exit"
    exit 1
fi

# Prints source directory
echo "Source: $source"

# Prompts the user for input
read -r -p "Enter the path of the destination backup drive (default is /run/media/linux_backup2): " destination

# Uses default if no input is given
destination=${destination:-/run/media/linux_backup2}

# Ensures the directory exists
if [ ! -d "$destination" ]; then
    echo "$destination does not exist"
    read -p "Press enter to exit"
    exit 1
fi

# Prints destination directory
echo "Destination: $destination"

# Syncs the source with the destination and checks if it was successful
if rsync -auhv --delete --progress "$source"/* "$destination"; then
    echo "${green}$source has successfully synced with $destination"
else
    echo "${red}$source has failed to sync with $destination"
fi
read -p "Press enter to exit"

