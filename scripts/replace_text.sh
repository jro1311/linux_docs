#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Prompts the user for input
read -r -p "Enter the path of the target directory (default is $HOME/Documents): " target_dir

# Uses default if no input is given
target_dir=${target_dir:-$HOME/Documents/}

# Expands ~ or $HOME to the full path
target_dir="${target_dir/#~/$HOME}"
target_dir="${target_dir/#\$HOME/$HOME}"

# Checks for directory
if [ ! -d "$target_dir" ]; then
    echo "$target_dir does not exist"
    read -p "Press enter to exit"
    exit 1
fi

# Prints target directory
echo "Target: $target_dir"

# Prompts the user for input
read -r -p "Enter the current text: " current_text

# Prompts the user for input
read -r -p "Enter the new text: " new_text

escape_sed() {
  # Reads from stdin, escapes &, \ and optionally / if you use / as your delimiter
  sed -e 's/[&\]/\\&/g'
}

# Replaces variables to avoid problems with escape characters
safe_current_text=$(printf '%s' "$current_text" | escape_sed)
safe_new_text=$(printf '%s' "$new_text" | escape_sed)

# Loops through all files in the directory and replaces text
find "$target_dir" -type f \
  -exec grep -Fq -- "$current_text" {} \; \
  -exec sed -i "s|$safe_current_text|$safe_new_text|g" {} \;
