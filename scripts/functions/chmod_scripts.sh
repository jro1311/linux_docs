#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
green=$(tput setaf 2)
reset=$(tput sgr0)

# Recursively finds all .sh files and sets them as executable
find "$HOME/Documents/linux_docs/scripts" -type f \
    -name "*.sh" \
    -exec chmod +x {} +

# Prints a conclusive message
echo "${green}All scripts are now executable. ${reset}"
