#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
green=$(tput setaf 2)
reset=$(tput sgr0)

# Recursively finds all .sh files and sets them as executable
find "$HOME/Documents/linux_docs/scripts" -type f \
    -name "*.sh" \
    -exec chmod +x {} +

echo "${green}All scripts are now executable. ${reset}"
