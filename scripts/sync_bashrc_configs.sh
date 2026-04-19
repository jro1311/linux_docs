#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2016

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in bashrc.d
shopt -s globstar nullglob

for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob

# Installs missing packages
packages=("rsync")
for package in "${packages[@]}"; do
    inverse_check "$package" \
        install_packages "$package"
done

mkdir -pv "$HOME/.bashrc.d"

source_dir="$HOME/Documents/linux_docs/configs/system/bash/bashrc.d/"
target_dir="$HOME/.bashrc.d/"

if [ ! -d "$source_dir" ]; then
    red_message "Error:" "'$source_dir' does not exist."
    exit 1
fi

# Adds the bashrc.d sourcing block to .bashrc if missing
if ! grep -q '^# Sources all .sh files in bashrc.d$' "$HOME/.bashrc"; then
    cat "$HOME/Documents/linux_docs/configs/system/bash/bashrc" >> "$HOME/.bashrc"
    green_message "Enabled:" "Recursive sourcing of '$HOME/.bashrc.d'."
fi

if rsync -auhvP --delete "$source_dir" "$target_dir"; then
    green_message "Success:" "'$source_dir' synced with '$target_dir'."
else
    red_message "Error:" "'$source_dir' failed to sync with '$target_dir'."
    exit 1
fi
