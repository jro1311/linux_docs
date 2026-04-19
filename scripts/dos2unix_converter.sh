#!/usr/bin/env bash
# shellcheck disable=SC2154

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
packages=("dos2unix")
for package in "${packages[@]}"; do
    inverse_check "$package" \
        install_packages "$package"
done

# Prompts the user for input
read -er -p "Enter the path of the target directory (default: $HOME/Documents/): " target_dir
    
# Use default if no input is given
target_dir=${target_dir:-$HOME/Documents/}

# Expand ~ or $HOME to the full path
target_dir="${target_dir/#~/$HOME}"
target_dir="${target_dir/#\$HOME/$HOME}"

# Validates directory
if [ ! -d "$target_dir" ]; then
    red_message "Error:" "'$target_dir' does not exist."
    exit 1
fi

green_message "Target:" "$target_dir"
read -r -p "Press ${green}enter${reset} to proceed, or ${red}ctrl+c${reset} to cancel: "

include_exts=(
    txt md conf cfg ini json yaml yml toml
    sh bash zsh
    js ts css html xml
    py rb lua
    c h cpp go rs
    csv tsv env properties
    dockerfile gitignore gitattributes
    mk
)

# Builds find predicates for extension-based files
find_args=()
for ext in "${include_exts[@]}"; do
    find_args+=( -iname "*.${ext}" -o )
done

unset 'find_args[${#find_args[@]}-1]'

# Collects extension-based files
mapfile -t ext_files < <(
    find "$target_dir" -type f \( "${find_args[@]}" \) -print
)

# Collects extensionless text files (MIME-checked)
noext_files=()
if command -v file >/dev/null 2>&1; then
    mapfile -t noext_files < <(
        find "$target_dir" -type f -not -name "*.*" -print0 |
        xargs -0 -r file --mime-type |
        awk -F: '$2 ~ /text\// {print $1}'
    )
else
    yellow_message "Skipped:" "Extensionless files (no 'file' utility available)."
fi

# Merges lists deterministically
all_files=( "${ext_files[@]}" "${noext_files[@]}" )

# Converts all files to format
for file in "${all_files[@]}"; do
    echo "Converting $file..."
    find "$target_dir" -type f \
        -name "*.$ext" \
        -exec dos2unix {} +
done

green_message "Success:" "Converted '$target_dir' to UNIX format."
