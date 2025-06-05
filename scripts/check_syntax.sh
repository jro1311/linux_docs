#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for bash script errors
find . -type f -name '*.sh' | while read -r script; do
    if ! bash -n "$script" > /dev/null 2>&1; then
        echo "Syntax error in $script:"
        bash -n "$script"
    fi
done


