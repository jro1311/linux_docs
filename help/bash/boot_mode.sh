#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for directory
if [ -d /sys/firmware/efi ]; then
    boot_mode="uefi"
    echo "${green}Boot Mode: UEFI ${reset}"
else
    boot_mode="bios"
    echo "${green}Boot Mode: Legacy BIOS ${reset}"
fi
