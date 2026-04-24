#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# shellcheck disable=SC2044
# Sources all .sh files in bashrc.d
for rc in $(find "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d" -type f -name '*.sh' 2>/dev/null); do
    . "$rc"
done

detect_system
define_steam_prefix

print_display

tweaks_applied=0

green_message "Supported Games:"
    printf '%s\n' \
    "[1] Fallout 4" \
    "[2] Fallout New Vegas" \
    "[3] Mirror's Edge" \
    "[4] Star Wars Jedi Knight: Jedi Academy" \
    "[5] The Elder Scrolls IV: Oblivion" \
    "[6] The Elder Scrolls V: Skyrim" \
    "[7] Torchlight" \
    "[x] none" | sed "s/^/  /"

while true; do
    read -er -p "Select game [1-7]: " num

    case "$num" in
        1) tweak_fallout4 "$path_prefix" && tweaks_applied=1 ;;
        2) tweak_fallout_new_vegas "$path_prefix" && tweaks_applied=1 ;;
        3) tweak_mirrors_edge "$path_prefix" && tweaks_applied=1 ;;
        4) tweak_jedi_academy "$path_prefix" && tweaks_applied=1 ;;
        5) tweak_oblivion "$path_prefix" && tweaks_applied=1 ;;
        6) tweak_skyrim "$path_prefix" && tweaks_applied=1 ;;
        7) tweak_torchlight "$path_prefix" && tweaks_applied=1 ;;
        x) ;;
        *) continue ;;
    esac

    break
done

if [ "$tweaks_applied" -eq 1 ]; then
    green_message "Success:" "Tweaks complete."
else
    yellow_message "Skipped:" "No tweaks were applied."
fi
