#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

ld_bash_dir="$HOME/Documents/linux_docs/configs/system/bash/bash.d"

shopt -s nullglob globstar
for file in "$ld_bash_dir"/**/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done
shopt -u nullglob globstar

detect_system
print_display

path_prefix=$(determine_steam_prefix)

tweaks_applied=0

green_message "Supported Games:"
printf '%s\n' \
    "[1] Batman: Arkham Asylum GOTY Edition" \
    "[2] Fallout 4" \
    "[3] Fallout New Vegas" \
    "[4] Mirror's Edge" \
    "[5] Star Wars Jedi Knight: Jedi Academy" \
    "[6] The Elder Scrolls IV: Oblivion" \
    "[7] The Elder Scrolls V: Skyrim" \
    "[8] Torchlight" \
    "[x] none" \
    | sed "s/^/  /" >&2

while true; do
    read -r -p "Select game [1-7]: " num

    case "$num" in
        1) tweak_batman_aa          "$path_prefix" && tweaks_applied=1 ;;
        2) tweak_fallout4           "$path_prefix" && tweaks_applied=1 ;;
        3) tweak_fallout_new_vegas  "$path_prefix" && tweaks_applied=1 ;;
        4) tweak_mirrors_edge       "$path_prefix" && tweaks_applied=1 ;;
        5) tweak_jedi_academy       "$path_prefix" && tweaks_applied=1 ;;
        6) tweak_oblivion           "$path_prefix" && tweaks_applied=1 ;;
        7) tweak_skyrim             "$path_prefix" && tweaks_applied=1 ;;
        8) tweak_torchlight         "$path_prefix" && tweaks_applied=1 ;;
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
