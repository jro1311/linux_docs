#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

. "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d/helpers/source.sh"
source_all "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d"

ensure_pkg "rsync"

mkdir -p "$HOME/.bashrc.d"

source_dir="$HOME/Documents/linux_docs/configs/system/bash/bashrc.d/"
target_dir="$HOME/.bashrc.d/"

if [ ! -d "$source_dir" ]; then
    red_message "Error:" "'$source_dir' does not exist."
    exit 1
fi

# Adds the bashrc.d sourcing block to .bashrc if missing
if ! grep -q '^# Load bashrc.d environment$' "$HOME/.bashrc"; then
    cat "$HOME/Documents/linux_docs/configs/system/bash/bashrc" >> "$HOME/.bashrc"
fi

if rsync -auhvP --delete "$source_dir" "$target_dir"; then
    green_message "Success:" "'$target_dir'"
else
    red_message "Failure:" "'$target_dir'"
    exit 1
fi
