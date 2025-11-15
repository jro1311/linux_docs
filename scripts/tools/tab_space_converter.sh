#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Prompts the user for input
read -er -p "Enter the path of the target directory (default: $HOME/Documents/): " target_dir

# Uses default if no input is given
target_dir=${target_dir:-$HOME/Documents/}

# Expands ~ or $HOME to the full path
target_dir="${target_dir/#~/$HOME}"
target_dir="${target_dir/#\$HOME/$HOME}"

# Validates directory
if [ ! -d "$target_dir" ]; then
    echo "${red}$target_dir does not exist. ${reset}"
    exit 1
fi

echo "${green}Target: $target_dir ${reset}"

ask_for_confirmation() {
    local prompt="$1"
    local answer

    while true; do
        read -r -p "$prompt [s/t]: " answer

        case "$answer" in
            [Ss]) return 0 ;;
            [Tt]) return 1 ;;
            *) echo "Enter a 's' or 't'." ;;
        esac
    done
}

if ask_for_confirmation "Convert to spaces or tabs?"; then
    echo "${green}Converting tabs to spaces... ${reset}"
    read -r -p "Press enter to proceed, or ctrl+c to cancel: "
    
    # Recursively finds all .md, .txt, and .sh files and converts them to spaces
    for ext in md txt sh; do
        find "$target_dir" -type f \
        -name "*.$ext" \
        -exec sh -c '
            for file do
                echo "Converting $file..."
                expand -t 4 -- "$file" > "$file.tmp" && mv "$file.tmp" "$file"
            done
        ' sh {} +
    done
else
    echo "${green}Converting spaces to tabs... ${reset}"
    read -r -p "Press enter to proceed, or ctrl+c to cancel: "

    # Recursively finds all .md, .txt, and .sh files and converts them to tabs
    for ext in md txt sh; do
        find "$target_dir" -type f \
        -name "*.$ext" \
        -exec sh -c '
            for file do
                echo "Converting $file..."
                unexpand -t 4 -- "$file" > "$file.tmp" && mv "$file.tmp" "$file"
            done
        ' sh {} +
    done
fi

echo "${green}Conversion complete. ${reset}"
