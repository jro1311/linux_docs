#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

bashd_dir="$HOME/Documents/linux_docs/configs/system/bash/bashrc.d"

for file in "$bashd_dir"/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done

for dir in helpers configure_packages install_packages; do
    for file in "$bashd_dir/$dir"/*.sh; do
        [ -e "$file" ] || continue
        . "$file"
    done
done

detect_system

if ! ensure_pkg "rsync" "curl" "jq"; then
    red_message "Error:" "Could not ensure package(s)."
    exit 1
fi

allow_overwrite=0

confirm "Overwrite existing package configs? [y/N]" && allow_overwrite=1

configure_btop  "$allow_overwrite"
configure_htop  "$allow_overwrite"
configure_micro "$allow_overwrite"
configure_nano  "$allow_overwrite"
configure_fonts "$allow_overwrite"
configure_mpv   "$allow_overwrite"
configure_brave "$allow_overwrite"
configure_mangohud "$allow_overwrite"
configure_redshift "$allow_overwrite"

if [ "$swapfile_exists" -eq 1 ] || [ "$swap_partition_exists" -eq 1 ]; then
    configure_zswap "$allow_overwrite"
else
    configure_zram "$allow_overwrite"
fi

green_message "Success:" "Copied all package configs to the system."
