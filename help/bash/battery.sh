#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# V1

# Enable nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Detect battery
battery_detected=0
batteries=(/sys/class/power_supply/BAT*)

if (( ${#batteries[@]} )); then
    battery_detected=1
fi

# Disable nullglob
shopt -u nullglob

# V2 (POSIX-compliant)

# Detect battery
battery_detected=0
if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
    battery_detected=1
fi

if [ "$battery_detected" -eq 1 ]; then
    echo "${green}Detected:${reset} Battery"
fi
