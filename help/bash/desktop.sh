#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Define the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')
echo "${green}Detected Desktop: $desktop ${reset}"

# Executes commands based on the desktop
case "$desktop" in
    "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
        ;;
    "budgie")
        ;;
    "cosmic")
        ;;
    "deepin")
        ;;
    "gnome"|"ubuntu")
        ;;
    "lxde")
        ;;
    "lxqt")
        ;;
    "mate")
        ;;
    "pantheon")
        ;;
    "kde"|"plasma")
        ;;
    "unity")
        ;;
    "xfce")
        ;;
    "x-cinnamon")
        ;;
    *)
        echo "${red}Unsupported desktop. ${reset}"
        ;;
esac
