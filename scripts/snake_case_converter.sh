#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Prompts the user for input
read -r -p "Enter the path of the directory to process (default is $HOME/Documents/): " target_dir

# Uses default if no input is given
target_dir=${target_dir:-$HOME/Documents/}

# Expands ~ or $HOME to the full path
target_dir="${target_dir/#~/$HOME}"
target_dir="${target_dir/#\$HOME/$HOME}"

# Ensures the directory exists
if [ ! -d "$target_dir" ]; then
    echo "Directory $target_dir does not exist. Exiting."
    exit 1
fi

# Prints target directory
echo "Target selected: $target_dir"

# Changes directory 
cd "$target_dir"

# Converts the current directory to snake_case
for file in *; do
  new_name=$(echo "$file" | tr '[:upper:]' '[:lower:]' | sed 's/[[:space:]]/_/g; s/__*/_/g')
  if [[ "$file" != "$new_name" ]]; then
    mv "$file" "$new_name"
  fi
done

# Prints a conclusive message to end the script
echo "Conversion complete."
