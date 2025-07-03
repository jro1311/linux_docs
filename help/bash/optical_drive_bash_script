#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for optical drive
if [ -e /dev/sr0 ]; then
    echo "Optical drive detected"
else
    echo "No optical drive detected"
fi

# Prints a conclusive message to end the script
echo "x is now installed"
read -p "Press enter to exit"
