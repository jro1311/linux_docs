#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Prompts the user for input
read -er -p "Enter the path of the source backup drive (default is /run/media/linux_backup1): " source

# Use default if no input is given
source=${source:-/run/media/linux_backup1}

# Checks for directory
if [ ! -d "$source" ]; then
    echo "${red}$source does not exist ${reset}"
    exit 1
fi

# Prints source directory
echo "${green}Source: $source ${reset}"

# Prompts the user for input
read -er -p "Enter the path of the destination backup drive (default is /run/media/linux_backup2): " destination

# Use default if no input is given
destination=${destination:-/run/media/linux_backup2}

# Checks for directory
if [ ! -d "$destination" ]; then
    echo "${red}$destination does not exist ${reset}"
    exit 1
fi

# Prints destination directory
echo "${green}Destination: $destination ${reset}"

# Prompts user for input
read -r -p "Press enter to proceed, or ctrl+c to cancel: "

# Syncs the source with the destination and checks if it was successful
if rsync -auhv --modify-window=1 --delete --progress "$source"/* "$destination"; then
    echo "${green}$source has successfully synced with $destination ${reset}"
else
    echo "${red}$source has failed to sync with $destination ${reset}"
fi

