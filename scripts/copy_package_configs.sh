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

ensure_packages "rsync" "curl" "jq"

allow_overwrite=0

confirmation "Overwrite existing package configs? [y/N]" && allow_overwrite=1

confirm_proceed

configure_btop "$allow_overwrite"
configure_htop "$allow_overwrite"
configure_micro "$allow_overwrite"
configure_nano "$allow_overwrite"
configure_fonts "$allow_overwrite"
configure_mpv "$allow_overwrite"

command -v mangohud >/dev/null 2>&1 && configure_mangohud "$allow_overwrite"
command -v redshift >/dev/null 2>&1 && configure_redshift "$allow_overwrite"

if ls /dev/zram* >/dev/null 2>&1; then
    configure_zram "$allow_overwrite"
else
    configure_swap "$allow_overwrite"
fi

green_message "Success:" "Copied all package configs to the system."
