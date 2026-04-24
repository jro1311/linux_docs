#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Checks for optical drive
if [ -e /dev/sr0 ]; then
    echo "${green}Detected:${reset} Optical drive"
else
    echo "${yellow}Not detected:${reset} Optical drive"
fi
