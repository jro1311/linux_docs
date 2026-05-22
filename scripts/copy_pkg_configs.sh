#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

ld_bash_dir="$HOME/Documents/linux_docs/configs/system/bash/bash.d"

for file in "$ld_bash_dir"/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done

for dir in helpers configure_packages install_packages; do
    for file in "$ld_bash_dir/$dir"/*.sh; do
        [ -e "$file" ] || continue
        . "$file"
    done
done

detect_system

if ! ensure_pkg "rsync" "curl" "jq" "speedtest-cli"; then
    red_message "Error:" "Could not ensure package(s)."
    exit 1
fi

skipped=0
allow_overwrite=0

confirm "Overwrite existing package configs? [y/N]" && allow_overwrite=1

configure_btop  "$allow_overwrite" && green_message "Success:" "btop"
configure_htop  "$allow_overwrite" && green_message "Success:" "htop"
configure_micro "$allow_overwrite" && green_message "Success:" "micro"
configure_nano  "$allow_overwrite" && green_message "Success:" "nano"
configure_fonts "$allow_overwrite" && green_message "Success:" "fonts"
configure_mpv   "$allow_overwrite" && green_message "Success:" "mpv"

configure_firefox       "$allow_overwrite" && [ "$skipped" -eq 0 ] && green_message "Success:" "firefox"
configure_librewolf     "$allow_overwrite" && [ "$skipped" -eq 0 ] && green_message "Success:" "librewolf"
configure_brave         "$allow_overwrite" && [ "$skipped" -eq 0 ] && green_message "Success:" "brave"
configure_mangohud      "$allow_overwrite" && [ "$skipped" -eq 0 ] && green_message "Success:" "mangohud"
configure_redshift      "$allow_overwrite" && [ "$skipped" -eq 0 ] && green_message "Success:" "redshift"
configure_kwinrc        "$allow_overwrite" && [ "$skipped" -eq 0 ] && green_message "Success:" "kwinrc"
configure_plasma_panel  "$allow_overwrite" && [ "$skipped" -eq 0 ] && green_message "Success:" "plasma panel"

if [ "$swapfile_exists" -eq 1 ] || [ "$swap_partition_exists" -eq 1 ]; then
    configure_zswap "$allow_overwrite" && green_message "Success:" "zswap"
else
    configure_zram "$allow_overwrite" && green_message "Success:" "zram"
fi
