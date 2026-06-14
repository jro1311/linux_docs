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

ensure_pkg "curl" "jq" "speedtest-cli" "zstd"

print_summary() {
    if [ "${#success_configs[@]}" -gt 0 ]; then
        green_message "Success:"
        printf '%s\n' "${success_configs[@]}" \
            | sort \
            | while IFS= read -r pkg; do
                printf '  %s\n' "$pkg"
              done
    fi

    if [ "${#skipped_configs[@]}" -gt 0 ]; then
        yellow_message "Skipped:"
        printf '%s\n' "${skipped_configs[@]}" \
            | sort \
            | while IFS= read -r pkg; do
                printf '  %s\n' "$pkg"
              done
    fi

    printf '\n'
}

success_configs=()
skipped_configs=()
overwrite=${1:-}
configure_btop_network_limits="${2:-}"
configure_compression_algorithm="${3:-}"

overwrite=$(resolve_flag \
    "$overwrite" \
    "Overwrite existing package configs? [y/N]")

configure_btop_network_limits=$(resolve_flag \
    "$configure_btop_network_limits" \
    "Run speedtest to set btop network limits? [y/N]")

configure_compression_algorithm=$(resolve_flag \
    "$configure_compression_algorithm" \
    "Run benchmark to determine optimal compression algorithm? [y/N]")

configure_btop  "$overwrite" "$configure_btop_network_limits"
configure_htop  "$overwrite"
configure_micro "$overwrite"
configure_nano  "$overwrite"
configure_fonts "$overwrite"
configure_mpv   "$overwrite"

configure_firefox   "$overwrite"
configure_librewolf "$overwrite"
configure_brave     "$overwrite"

configure_redshift  "$overwrite"
configure_mangohud  "$overwrite"
configure_plasma    "$overwrite"
configure_journald  "$overwrite"

if [ "$swapfile_exists" -eq 1 ] || [ "$swap_partition_exists" -eq 1 ]; then
    configure_zswap "$overwrite" "$configure_compression_algorithm"
else
    configure_zram "$overwrite" "$configure_compression_algorithm"
fi

print_summary
