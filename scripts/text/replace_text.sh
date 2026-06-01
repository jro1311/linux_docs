#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

ld_bash_dir="$HOME/Documents/linux_docs/configs/system/bash/bash.d"

shopt -s nullglob globstar
for file in "$ld_bash_dir"/**/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done
shopt -u nullglob globstar

if ! ensure_pkg "perl"; then
    red_message "Error:" "Could not ensure package(s)."
    exit 1
fi

target_dir=$(input_directory "Enter target directory (default: $HOME/Documents)" "$HOME/Documents")
green_message "Target:" "$target_dir"

while true; do
    read -r -p "Enter current text: " current_text

    if [ -z "$current_text" ]; then
        red_message "Error:" "No text entered."
        exit 1
    fi

    matches="$(
        sudo_run_passthrough find "$target_dir" \
            -type d -path "*/.git" -prune -o \
            -type f -exec grep -Fl -- "$current_text" {} \; \
        2>/dev/null
    )"

    if [ -z "$matches" ]; then
        yellow_message "No matches found:" "'$current_text' not found in any files."
        continue
    fi

    read -r -p "Enter new text: " new_text

    yellow_message "Pending modifications:"
    printf "%s\n" "$matches" | sed "s/^/  /"

    confirm_proceed

    # shellcheck disable=SC2016
    # Applies text replacement to each matched file
    while IFS= read -r file; do
        sudo_run_passthrough env \
            current_text="$current_text" \
            new_text="$new_text" \
            perl -pi -e 's/\Q$ENV{current_text}\E/$ENV{new_text}/g' "$file"
    done <<< "$matches"

    green_message "Success:" "Replaced text in '$target_dir'."

    confirm "Continue? [y/N]" || break
done
