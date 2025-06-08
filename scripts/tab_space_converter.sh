#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Function to get a valid yes or no response
get_confirmation() {
    while true; do
        read -r -p "Convert to spaces or tabs, or cancel? (s/t/c): " choice
        case "$choice" in
            [Ss]* ) return 0;;
            [Tt]* ) return 1;;
            [Cc]* ) exit 1;;
            * ) echo "Enter a 't','s' or 'c'";;
        esac
    done
}

# Call the function and act based on the user's response
if get_confirmation; then
    echo "Converting tabs to spaces"
    # Prompts the user for input
    read -r -p "Enter the directory to process (default is $HOME/Documents/): " target_dir

    # Uses default if no input is given
    target_dir=${target_dir:-$HOME/Documents/}

    # Expands ~ or $HOME to the full path
    target_dir="${target_dir/#~/$HOME}"
    target_dir="${target_dir/#\$HOME/$HOME}"

    # Ensures the directory exists
    if [ ! -d "$target_dir" ]; then
        echo "$target_dir does not exist"
        read -p "Press enter to exit"
        exit 1
    fi
    
    # Prints target directory
    echo "Target: $target_dir"
    
    # Recursively finds all .md, .txt, and .sh files and converts them to spaces
    for ext in md txt sh; do
        find "$target_dir" -type f -name "*.$ext" -exec sh -c '
            for file do
                echo "Converting $file..."
                expand -t 4 -- "$file" > "$file.tmp" && mv "$file.tmp" "$file"
            done
        ' sh {} +
    done
else
    echo "Converting spaces to tabs"
    # Prompts the user for the directory
    read -r -p "Enter the directory to process (default is $HOME/Documents/): " target_dir

    # Uses default if no input is given
    target_dir=${target_dir:-$HOME/Documents/}

    # Expands ~ or $HOME to the full path
    target_dir="${target_dir/#~/$HOME}"
    target_dir="${target_dir/#\$HOME/$HOME}"

    # Ensures the directory exists
    if [ ! -d "$target_dir" ]; then
        echo "$target_dir does not exist"
        read -p "Press enter to exit"
        exit 1
    fi
    
    # Prints target directory
    echo "Target: $target_dir"

    # Recursively finds all .md, .txt, and .sh files and converts them to tabs
    for ext in md txt sh; do
        find "$target_dir" -type f -name "*.$ext" -exec sh -c '
            for file do
                echo "Converting $file..."
                unexpand -t 4 -- "$file" > "$file.tmp" && mv "$file.tmp" "$file"
            done
        ' sh {} +
    done
fi

# Prints a conclusive message
echo "Conversion complete"
read -p "Press enter to exit"
