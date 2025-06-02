#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Function to get a valid yes or no response
get_confirmation() {
    while true; do
        read -pr "Convert to spaces or tabs, or cancel? (s/t/c): " choice
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
    # Prompts the user for the directory
    read -pr "Enter the directory to process (default is $HOME/Documents/): " target_dir

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

    # Uses $target_dir in the find command
    find "$target_dir" -type f $ -name "*.md" -o -name "*.txt" -o -name "*.sh" $ -exec sh -c '
        for file do
            echo "Converting $file..."
            expand -t 4 -- "$file" > "$file.tmp" && mv "$file.tmp" "$file"
        done
    ' sh {} +
else
    echo "Converting spaces to tabs"
    # Prompts the user for the directory
    read -pr "Enter the directory to process (default is $HOME/Documents/): " target_dir

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

    # Use $target_dir in the find command
    find "$target_dir" -type f $ -name "*.md" -o -name "*.txt" -o -name "*.sh" $ -exec sh -c '
        for file do
            echo "Converting $file..."
            unexpand -t 4 -- "$file" > "$file.tmp" && mv "$file.tmp" "$file"
        done
    ' sh {} +
fi

# Prints a conclusive message to end the script
echo "Conversion complete."
