#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

ld_bash_dir="$HOME/Documents/linux_docs/configs/system/bash/bash.d"

for file in "$ld_bash_dir"/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done

for dir in helpers configure_packages install_packages; do
    for file in "$ld_bash_dir/$dir"/*.sh; do
        [ -e "$file" ] || continue
        . "$file"
    done
done

if ! ensure_pkg "rsync"; then
    red_message "Error:" "Could not ensure package(s)."
    exit 1
fi

mkdir -p "$HOME/.ld_bash.d"

source_dir="$HOME/Documents/linux_docs/configs/system/bash/bash.d"
target_dir="$HOME/.ld_bash.d"

if [ ! -d "$source_dir" ]; then
    red_message "Error:" "'$source_dir' does not exist."
    exit 1
fi

src_template="$HOME/Documents/linux_docs/configs/system/bash/bashrc"
marker="# Load ld_bash.d runtime environment"

if [ ! -f "$HOME/.bashrc" ]; then
    cp "$src_template" "$HOME/.bashrc"
elif ! grep -q "^$marker" "$HOME/.bashrc"; then
    printf '\n'
    cat "$src_template" >> "$HOME/.bashrc"
fi

rsync_flags=(
    -a
    -u
    -h
    -v
    -P
    --delete
)

if rsync "${rsync_flags[@]}" "$source_dir/" "$target_dir/"; then
    green_message "Success:" "$target_dir"
else
    red_message "Failure:" "$target_dir"
    exit 1
fi
