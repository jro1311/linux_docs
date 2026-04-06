#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
if command -v tput &>/dev/null; then
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    yellow=$(tput setaf 3)
    blue=$(tput setaf 4)
    reset=$(tput sgr0)
else
    # Fallback for systems without tput
    red=$'\033[31m'
    green=$'\033[32m'
    yellow=$'\033[33m'
    blue=$'\033[34m'
    reset=$'\033[0m'
fi

# Define the boot drive
boot_drive="$(df / | tail -1 | awk '{print $1}')"

# Checks if a boot drive was detected
if [[ -z "$boot_drive" ]]; then
    echo "${red}Error:${reset} No boot drive detected."
    exit 1
fi

# Checks if the device is an NVMe drive
if [[ $boot_drive == /dev/nvme* ]]; then

    # Extracts the parent NVMe device (without partition number)
    parent_device="${boot_drive//p[0-9]*/}"

    # Checks for NVMe specific information
    if [ -e "/sys/block/$(basename "$parent_device")/queue/rotational" ]; then

        if [ "$(cat "/sys/block/$(basename "$parent_device")/queue/rotational")" -eq 0 ]; then
            echo "${green}Boot Drive:${reset} NVMe SSD"
        else
            echo "${green}Boot Drive:${reset} NVMe HDD (?)"
        fi

    else
        echo "${red}Error:${reset} Unknown drive type."
    fi

# Checks if the device is an eMMC storage
elif [[ $boot_drive == /dev/mmcblk* ]]; then
    echo "${green}Boot Drive Detected:${reset} eMMC"

else
    # Checks for SATA and other block devices
    if [ -e "/sys/block/$(basename "$boot_drive")/queue/rotational" ]; then

        if [ "$(cat /sys/block/"$(basename "$boot_drive")"/queue/rotational)" -eq 0 ]; then
            echo "${green}Boot Drive:${reset} SATA SSD"
        else
            echo "${green}Boot Drive:${reset} HDD"
        fi

    else
        echo "${red}Error:${reset} Unknown drive type."
    fi
fi
