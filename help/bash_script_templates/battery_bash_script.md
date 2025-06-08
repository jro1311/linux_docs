#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Function to check for battery
check_battery() {
    if [ -d /sys/class/power_supply/BAT0 ] || [ -d /sys/class/power_supply/BAT1 ]; then
        return 0  # Battery detected
    else
        return 1  # No battery detected
    fi
}

# Checks for battery
if check_battery; then
    echo "Battery detected"
else
    echo "No battery detected"
fi

# Prints a conclusive message
echo "x is now installed"
