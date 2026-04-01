#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
if command -v tput &>/dev/null; then
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    yellow=$(tput setaf 3)
    blue=$(tput setaf 4)
    reset=$(tput sgr0)
else
    # Fallback for systems without tput
    red=$'\033[31m'
    green=$'\033[32m'
    yellow=$'\033[33m'
    blue=$'\033[34m'
    reset=$'\033[0m'
fi

# Define the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')
echo "${green}Desktop:${reset} $desktop"

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
        echo "${red}Unsupported desktop.${reset}"
        ;;
esac
