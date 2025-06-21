#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Detects the desktop environment or window manager and stores in a variable, shortens it, then converts it into lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Prints the detected desktop
echo "Detected Desktop: $desktop"

# Conditional execution based on the desktop environment
case "$desktop" in
    "awesome")
        ;;
    "bspwm")
        ;;
    "budgie")
        ;;
    "cosmic")
        ;;
    "deepin")
        ;;
    "enlightenment")
        ;;
    "fluxbox")
        ;;
    "gnome")
        ;;
    "hyprland")
        ;;
    "i3")
        ;;
    "jwm")
        ;;
    "lxde")
        ;;
    "lxqt")
        ;;
    "mate")
        ;;
    "miracle-wm")
        ;;
    "openbox")
        ;;
    "pantheon")
        ;;
    "plasma")
        ;;
    "sway")
        ;;
    "unity")
        ;;
    "xfce")
        ;;
    "x-cinnamon")
        ;;
    *)
        echo "Unsupported desktop"
        read -p "Press enter to continue"
        ;;
esac


# Prints a conclusive message
echo "x is now installed"
read -p "Press enter to exit"
