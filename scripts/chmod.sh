#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Recursively finds all .sh files and sets them as executable
find "$HOME/Documents/linux_docs/scripts" -type f -name "*.sh" -exec chmod +x {} +

# Prints a conclusive message to end the script
echo "All bash scripts are now executable."
