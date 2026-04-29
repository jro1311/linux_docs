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

if ! ensure_pkg "rsync"; then
    red_message "Error:" "Could not ensure package(s)."
    exit 1
fi

mkdir -p "$HOME/.bashrc.d"

source_dir="$HOME/Documents/linux_docs/configs/system/bash/bashrc.d/"
target_dir="$HOME/.bashrc.d/"

if [ ! -d "$source_dir" ]; then
    red_message "Error:" "'$source_dir' does not exist."
    exit 1
fi

if ! grep -q '^# Load bashrc.d environment$' "$HOME/.bashrc"; then
    cat "$HOME/Documents/linux_docs/configs/system/bash/bashrc" >> "$HOME/.bashrc"
fi

rsync_flags=(
    -a
    -u
    -h
    -v
    -P
    --delete
)

if rsync "${rsync_flags[@]}" "$source_dir" "$target_dir"; then
    green_message "Success:" "'$target_dir'"
else
    red_message "Failure:" "'$target_dir'"
    exit 1
fi
