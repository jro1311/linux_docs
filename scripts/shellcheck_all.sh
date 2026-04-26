#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

# shellcheck disable=SC2044
# Sources all .sh files in bashrc.d
for rc in $(find "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d" -type f -name '*.sh' 2>/dev/null); do
    . "$rc"
done

ensure_pkg "shellcheck"

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
