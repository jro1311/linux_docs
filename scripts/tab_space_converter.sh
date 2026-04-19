#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc
shopt -u globstar nullglob

# Checks that packages are installed
packages=("shfmt")
for package in "${packages[@]}"; do
    inverse_check "$package" \
        install_packages "$package"
done

# Prompts the user for input
read -er -p "Enter the path of the target directory (default: $HOME/Documents/): " target_dir

# Uses default if no input is given
target_dir=${target_dir:-$HOME/Documents/}

# Expands ~ or $HOME to the full path
target_dir="${target_dir/#~/$HOME}"
target_dir="${target_dir/#\$HOME/$HOME}"

# Validates directory
if [ ! -d "$target_dir" ]; then
    red_message "Error:" "'$target_dir' does not exist."
    exit 1
fi

green_message "Target:" "$target_dir"

format=""
format_cmd=""

green_message "Formats:"
printf '%s\n' \
"[1] Tabs" \
"[2] Spaces"

while true; do
    read -r -p "Enter format: " number

    if [ -z "$number" ]; then
        red_message "Error:" "No format provided."
        continue
    fi

    case "$number" in
        "1")
            format="tabs"
            format_cmd="unexpand"
            ;;
        "2")
            format="spaces"
            format_cmd="expand"
            ;;
        *)
            echo "Enter a number 1 or 2."
            continue
    esac

    break
done

while true; do
    read -r -p "Enter indentation width: " in_width

    if [ -z "$in_width" ]; then
        red_message "Error:" "No indentation width provided."
        continue
    fi

    case "$in_width" in
        *[!0-9]*)
            red_message "Error:" "Indentation width must be a non-negative integer."
            continue
            ;;
    esac

    break
done

if [ -n "$format" ]; then
     read -r -p "Press ${green}enter${reset} to proceed, or ${red}ctrl+c${reset} to cancel: "

    # Recursively finds all .md, .txt, and .sh files and converts them
    for ext in md txt sh; do
        sudo_run_passthrough find "$target_dir" -type f \
            -name "*.$ext" \
            -exec sh -c '
                format_cmd="$1"
                width="$2"
                shift 2

                for file do
                    echo "Converting $file..."

                    case "$file" in
                        *.sh)
                            if command -v shfmt >/dev/null 2>&1; then

                                if [ "$format_cmd" = "expand" ]; then
                                    shfmt -i "$width" -ci -sr -ln bash -- "$file" > "$file.tmp"
                                else
                                    shfmt -i 0 -ci -sr -ln bash -- "$file" > "$file.tmp"
                                fi

                                mv "$file.tmp" "$file"
                                continue
                            fi
                            ;;
                    esac

                    "$format_cmd" -t "$width" -- "$file" > "$file.tmp" \
                        && mv "$file.tmp" "$file"
                done
            ' sh "$format_cmd" "$in_width" {} +
    done

    green_message "Success:" "Converted '$target_dir' to $format."
fi
