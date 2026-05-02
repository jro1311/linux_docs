#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Checks for optical drive
if [ -e /dev/sr0 ]; then
    echo "${green}Optical Drive Detected:${reset} Yes"
else
    echo "${green}Optical Drive Detected:${reset} No"
fi
