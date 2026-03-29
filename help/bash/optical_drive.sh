#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for optical drive
if [ -e /dev/sr0 ]; then
    echo "${green}Optical drive detected. ${reset}"
else
    echo "${yellow}No optical drive detected. ${reset}"
fi
