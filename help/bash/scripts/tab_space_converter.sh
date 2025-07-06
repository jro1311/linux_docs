#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Function for user input
get_answer() {
    while true; do
        read -r -p "Convert to spaces, tabs, or cancel? (s/t/c): " answer
        case "$answer" in
            [Ss]* ) return 0;;
            [Tt]* ) return 1;;
            [Cc]* ) exit 1;;
            * ) echo "Enter a 's','t' or 'c'";;
        esac
    done
}

# Checks for answer
if get_answer; then
    echo "Converting tabs to spaces..."
    # Prompts the user for input
    read -er -p "Enter the path of the target directory (default is $HOME/Documents/): " target_dir

    # Use default if no input is given
    target_dir=${target_dir:-$HOME/Documents/}

    # Expand ~ or $HOME to the full path
    target_dir="${target_dir/#~/$HOME}"
    target_dir="${target_dir/#\$HOME/$HOME}"

    # Checks for directory
    if [ ! -d "$target_dir" ]; then
        echo "$target_dir does not exist"
        exit 1
    fi
    
    # Prints target directory
    echo "Target: $target_dir"
    
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
    echo "Converting spaces to tabs..."
    # Prompts the user for the directory
    read -er -p "Enter the path of the target directory (default is $HOME/Documents/): " target_dir

    # Use default if no input is given
    target_dir=${target_dir:-$HOME/Documents/}

    # Expand ~ or $HOME to the full path
    target_dir="${target_dir/#~/$HOME}"
    target_dir="${target_dir/#\$HOME/$HOME}"

    # Checks for directory
    if [ ! -d "$target_dir" ]; then
        echo "$target_dir does not exist"
        exit 1
    fi
    
    # Prints target directory
    echo "Target: $target_dir"

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

# Prints a conclusive message
echo "Conversion complete"
