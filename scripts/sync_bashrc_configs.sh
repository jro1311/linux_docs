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

ensure_pkg "rsync"

mkdir -p "$HOME/.bashrc.d"

source_dir="$HOME/Documents/linux_docs/configs/system/bash/bashrc.d/"
target_dir="$HOME/.bashrc.d/"

if [ ! -d "$source_dir" ]; then
    red_message "Error:" "'$source_dir' does not exist."
    exit 1
fi

# Adds the bashrc.d sourcing block to .bashrc if missing
if ! grep -q '^# Sources all .sh files in bashrc.d$' "$HOME/.bashrc"; then
    cat "$HOME/Documents/linux_docs/configs/system/bash/bashrc" >> "$HOME/.bashrc"
fi

if rsync -auhvP --delete "$source_dir" "$target_dir"; then
    green_message "Success:" "'$target_dir'"
else
    red_message "Failure:" "'$target_dir'"
    exit 1
fi
