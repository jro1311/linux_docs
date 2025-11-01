#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Prompts the user for input
read -er -p "Enter the path of the target directory (default is $HOME/Documents): " target_dir

# Use default if no input is given
target_dir=${target_dir:-$HOME/Documents}

# Expand ~ or $HOME to the full path
target_dir="${target_dir/#~/$HOME}"
target_dir="${target_dir/#\$HOME/$HOME}"

# Checks for directory
if [ ! -d "$target_dir" ]; then
    echo "${red}$target_dir does not exist ${reset}"
    exit 1
fi

# Prints target directory
echo "${green} Target: $target_dir ${reset}"

# Prompts the user for input
read -r -p "Enter the current text: " current_text
read -r -p "Enter the new text: " new_text
read -r -p "Press enter to proceed, or ctrl+c to cancel: "

# Escape special characters for sed
safe_current_text=$(printf '%s' "$current_text" | sed 's/[][$$&*|/^!#]/\\&/g')
safe_new_text=$(printf '%s' "$new_text" | sed 's/[][$$&*|/^!#]/\\&/g')

# Loops through all files in the directory and replaces text
find "$target_dir" -type f \
  -exec grep -Fq -- "$current_text" {} \; \
  -exec sed -i "s|$safe_current_text|$safe_new_text|g" {} \;
  
# Prints a conclusive message
echo "${green}Replacement complete ${reset}"
