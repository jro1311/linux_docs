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

if ! ensure_pkg "shellcheck"; then
    red_message "Error:" "Could not ensure package(s)."
    exit 1
fi

dirs=(
    "$HOME/Documents/linux_docs/scripts"
    "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d"
)

# Runs shellcheck on all .sh files and tracks whether any errors occur
error_found=0
while IFS= read -r -d '' script; do
    if ! shellcheck -x "$script"; then
        error_found=1
    fi
done < <(find "${dirs[@]}" -type f -name '*.sh' -print0)

if [ "$error_found" -eq 0 ]; then
    green_message "Success:" "No errors were found in any script."
fi

exit "$error_found"
