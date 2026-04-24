#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define command to get display information
display_cmd=""
if command -v xrandr >/dev/null 2>&1; then
    display_cmd="xrandr"
elif command -v wlr-randr >dev/null 2>&1; then
    display_cmd="wlr-randr"
fi

# Get display information
if [ -n "$display_cmd" ]; then
    display=$("$display_cmd" | grep "primary" -A1 | tail -1 | awk '{print $1}')
    display_w=$(echo "$display" | cut -d'x' -f1)
    display_h=$(echo "$display" | cut -d'x' -f2)
    refresh_rate=$("$display_cmd"  | grep "primary" -A1 | tail -1 | awk '{print $2}' | sed 's/[*+]//g' | xargs printf "%.0f")
    max_fps_target="$(awk "BEGIN {printf \"%.0f\", int(($refresh_rate - 5) / 5 + 0.5) * 5}")"

    # Prints display information
    echo "${green}Display Resolution:${reset} $display"
    echo "${green}Display Width:${reset} $display_w"
    echo "${green}Display Height:${reset} $display_h"
    echo "${green}Display Refresh Rate:${reset} $refresh_rate Hz"
    echo "${green}Max FPS Target:${reset} $max_fps_target FPS"
fi
