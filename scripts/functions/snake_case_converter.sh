#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Prompts for target directory (default: $HOME/Documents)
read -er -p "Enter the path of the target directory (default is $HOME/Documents/): " target_dir
target_dir=${target_dir:-$HOME/Documents/}

# Expands ~ or $HOME to the full path
target_dir="${target_dir/#~/$HOME}"
target_dir="${target_dir/#\$HOME/$HOME}"

# Validates directory
if [ ! -d "$target_dir" ]; then
    echo "${red}$target_dir does not exist. ${reset}"
    exit 1
fi

# Prints target directory
echo "${green}Target: $target_dir ${reset}"

# Prompts user to continue
read -r -p "Press enter to proceed, or ctrl+c to cancel: "

# Changes directory
cd "$target_dir"

# Convert filenames to snake_case (non-recursive)
for file in *; do
    new_name=$(echo "$file" | tr '[:upper:]' '[:lower:]' | sed 's/[[:space:]]/_/g; s/__*/_/g')
    if [[ "$file" != "$new_name" ]]; then
        mv -v "$file" "$new_name"
    fi
done

echo "${green}Conversion complete. ${reset}"
