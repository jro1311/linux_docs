#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

[ -n "$desktop" ] && echo "${green}Desktop:${reset} $desktop"

# Executes commands based on the desktop
case "$desktop" in
    awesome|enlightenment|fluxbox|hyprland|i3|openbox|qtile|sway|xmonad|*wm)
        ;;
    budgie)
        ;;
    cosmic)
        ;;
    deepin)
        ;;
    gnome|ubuntu)
        ;;
    lxde)
        ;;
    lxqt)
        ;;
    mate)
        ;;
    pantheon)
        ;;
    kde|plasma)
        ;;
    unity)
        ;;
    xfce)
        ;;
    x-cinnamon)
        ;;
    *)
        echo "${red}Unsupported desktop.${reset}"
        ;;
esac
