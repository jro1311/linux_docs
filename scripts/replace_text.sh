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

ensure_pkg "perl"

target_dir=$(input_directory "Enter target directory (default: $HOME/Documents)" "$HOME/Documents")
green_message "Target:" "$target_dir"

read -r -p "Enter current text: " current_text

if [ -z "$current_text" ]; then
    red_message "Error:" "No text entered."
    exit 1
fi

read -r -p "Enter new text: " new_text

matches="$(
    sudo_run_passthrough \
        find "$target_dir" \
            \( -path '*/.git/*' -prune \) -o \
            -type f -exec grep -Fl -- "$current_text" {} \; \
        2>/dev/null
)"

if [ -z "$matches" ]; then
    yellow_message "No matches found:" "'$current_text' not found in any files."
    exit 0
fi

yellow_message "Pending modifications:"
printf "%s\n" "$matches" | sed "s/^/  /"

confirm_proceed

# shellcheck disable=SC2016
# Applies text replacement to each matched file
printf "%s\n" "$matches" | while IFS= read -r file; do
    sudo_run_passthrough env \
        current_text="$current_text" \
        new_text="$new_text" \
        perl -pi -e 's/\Q$ENV{current_text}\E/$ENV{new_text}/g' "$file"
done
  
green_message "Success:" "Replaced text in '$target_dir'."
