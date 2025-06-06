#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Variable to track if any script fails the syntax check
error_found=0

# Recursively finds all .sh files and checks each for errors
while IFS= read -r -d '' script; do
    if ! bash -n "$script" > /dev/null 2>&1; then
        echo "Syntax errors found in $script:"
        bash -n "$script"
        error_found=1
    fi
done < <(find . -type f -name '*.sh' -print0)

if [[ $error_found -eq 0 ]]; then
    echo "No syntax errors found in any script."
fi
