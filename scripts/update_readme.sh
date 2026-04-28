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

dir="$HOME/Documents/linux_docs"
file="$dir/readme.md"

if ! command -v tree >/dev/null 2>&1; then
    red_message "Error:" "'tree' command not found."
    exit 1
fi

if [ ! -d "$dir" ]; then
    red_message "Error:" "Missing '$dir'."
    exit 1
fi

cd "$dir" 

tree -a -C -I '.git'

{
    echo '```'
    tree -a -I '.git'
    echo '```'
} > "$file"

# Removes summary lines
sed -i '/^[0-9]\+ directories, [0-9]\+ files$/d' "$file"

green_message "Success:" "Updated readme.md."
