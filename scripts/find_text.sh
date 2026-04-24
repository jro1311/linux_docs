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

target_dir=$(input_directory "Enter target directory (default: $HOME/Documents)" "$HOME/Documents")
green_message "Target:" "$target_dir"

read -er -p "Enter text: " text

if [ -z "$text" ]; then
    red_message "Error:" "No text provided."
    exit 1
fi

include_exts=(
    txt md conf cfg ini json yaml yml toml
    sh bash zsh
    js ts css html xml
    py rb lua
    c h cpp go rs
    csv tsv env properties
    dockerfile gitignore gitattributes
    mk
)


find_args=()
for ext in "${include_exts[@]}"; do
    find_args+=( -iname "*.${ext}" -o )
done

unset 'find_args[${#find_args[@]}-1]'

mapfile -t ext_files < <(
    find "$target_dir" -type f \( "${find_args[@]}" \) -print
)

# Collects extensionless files that are confirmed text via MIME detection
noext_files=()
if command -v file >/dev/null 2>&1; then
    mapfile -t noext_files < <(
        find "$target_dir" -type f -not -name "*.*" -print0 |
        xargs -0 -r file --mime-type |
        awk -F: '$2 ~ /text\// {print $1}'
    )
else
    yellow_message "Skipped:" "Extensionless files (no 'file' utility available)."
fi

all_files=( "${ext_files[@]}" "${noext_files[@]}" )

text_found=0
for file in "${all_files[@]}"; do
    if grep -Fq -- "$text" "$file"; then
        green_message "FILE:" "$file"
        grep -Fn -- "$text" "$file" | sed "s/^/  /"
        printf '\n'
        text_found=1
    fi
done

if [ "$text_found" -eq 0 ]; then
    yellow_message "No matches found:" "'$text' was not found in '$target_dir'."
fi
