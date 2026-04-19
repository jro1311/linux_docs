#!/usr/bin/env bash
# shellcheck source=/dev/null

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in bashrc.d
shopt -s globstar nullglob

for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob

# Installs missing packages
packages=("shellcheck")
for package in "${packages[@]}"; do
    inverse_check "$package" \
        install_packages "$package"
done

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
