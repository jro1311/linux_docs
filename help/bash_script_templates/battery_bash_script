#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Enables nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Detects batteries and stores in a variable
batteries=(/sys/class/power_supply/BAT*)

# Checks for battery
if (( ${#batteries[@]} )); then
    echo "Detected System: Laptop"
else
    echo "Detected System: Desktop"
fi

# Prints a conclusive message
echo "x is now installed"
read -p "Press enter to exit"
