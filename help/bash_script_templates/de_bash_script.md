#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Detects the desktop environment and stores in a variable, then converts it into lowercase
desktop_env=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Prints the detected desktop environment
echo "Detected: $desktop_env"

# Conditional execution based on the desktop environment
case "$desktop_env" in
    "gnome")
        ;;
    "plasma")
        ;;
    "lxqt")
        ;;
    "lxde")
        ;;
    "mate")
        ;;
    "xfce")
        ;;
    "x-cinnamon")
        ;;
    "budgie")
        ;;
    *)
        echo "Nothing to do for $desktop_env"
        ;;
esac

# Prints a conclusive message to end the script
echo "x is now installed."
