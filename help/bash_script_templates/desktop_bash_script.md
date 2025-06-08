#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Detects the desktop environment and stores in a variable, then converts it into lowercase
desktop_env=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Prints the detected desktop environment
echo "Detected: $desktop_env"

# Conditional execution based on the desktop environment
case "$desktop_env" in
    "budgie")
        ;;
    "cosmic")
        ;;
    "deepin")
        ;;
    "gnome")
        ;;
    "lxde")
        ;;
    "lxqt")
        ;;
    "mate")
        ;;
    "pantheon")
        ;;
    "plasma")
        ;;
    "unity")
        ;;
    "xfce")
        ;;
    "x-cinnamon")
        ;;
    *)
        echo "Unsupported desktop environment: $desktop_env."
        ;;
esac


# Prints a conclusive message to end the script
echo "x is now installed."
