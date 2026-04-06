#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc
shopt -u globstar nullglob

# Checks that packages are installed
packages=("shellcheck")
for package in "${packages[@]}"; do
    inverse_check "$package" \
        install_packages "$package"
done

dirs=(
    "$HOME/Documents/linux_docs/scripts"
    "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d"
)

# Recursively checks all .sh files for errors
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
