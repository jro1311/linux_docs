#!/bin/bash

# Ensures that scripts exit immediately when any error occurs, and it treats unset variables and pipeline failures as errors
set -euo pipefail

# Function to check for battery presence
check_battery() {
    if [ -d /sys/class/power_supply/BAT0 ] || [ -d /sys/class/power_supply/BAT1 ]; then
        return 0  # Battery detected
    else
        return 1  # No battery detected
    fi
}

# Check for battery
if check_battery; then
    echo "Battery detected"
else
    echo "No battery detected"
fi

# Prints a conclusive message to end the script
echo "x is now installed."
