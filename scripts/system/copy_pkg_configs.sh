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

if ! ensure_pkg "rsync" "curl" "jq" "speedtest-cli"; then
    red_message "Error:" "Could not ensure package(s)."
    exit 1
fi

print_summary() {
    if [ "${#success_configs[@]}" -gt 0 ]; then
        green_message "Success:"
        for pkg in "${success_configs[@]}"; do
            printf '  %s\n' "$pkg"
        done
    fi

    if [ "${#skipped_configs[@]}" -gt 0 ]; then
        yellow_message "Skipped:"
        for pkg in "${skipped_configs[@]}"; do
            printf '  %s\n' "$pkg"
        done
    fi
}

success_configs=()
skipped_configs=()
allow_overwrite=0

confirm "Overwrite existing package configs? [y/N]" && allow_overwrite=1

configure_btop  "$allow_overwrite"
configure_htop  "$allow_overwrite"
configure_micro "$allow_overwrite"
configure_nano  "$allow_overwrite"
configure_fonts "$allow_overwrite"
configure_mpv   "$allow_overwrite"

configure_firefox   "$allow_overwrite"
configure_librewolf "$allow_overwrite"
configure_brave     "$allow_overwrite"

configure_redshift  "$allow_overwrite"
configure_mangohud  "$allow_overwrite"

configure_plasma "$allow_overwrite"

if [ "$swapfile_exists" -eq 1 ] || [ "$swap_partition_exists" -eq 1 ]; then
    configure_zswap "$allow_overwrite"
else
    configure_zram "$allow_overwrite"
fi

print_summary
