#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# shellcheck disable=SC2044
# Sources all .sh files in bashrc.d
for rc in $(find "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d" -type f -name '*.sh' 2>/dev/null); do
    . "$rc"
done

ensure_packages "git"

green_message "GitHub Repositories:"
printf '%s\n' \
    "[1] linux_docs" \
    "[2] custom" \
    "[x] cancel" | sed "s/^/  /"

while true; do
    read -r -p "Select repo [1-2]: " num

    case "$num" in
        1)
            local_dir="$HOME/Documents/linux_docs"
            repo_url=https://github.com/jro1311/linux_docs.git
            ;;
        2)
            local_dir=$(input_directory "Enter local directory")
            ;;
        x) exit 0 ;;
        *) continue ;;
    esac

    break
done

if [ ! -d "$local_dir" ]; then
    red_message "Error:" "'$local_dir' does not exist."
    exit 1
fi

backup_dir="${local_dir}_old"

if ! curl -sIf "$repo_url" >/dev/null 2>&1; then
    red_message "Error:" "Failed to reach '$repo_url'"
    exit 1
fi

repo_name=$(basename "$repo_url" .git)

green_message "Local Directory:" "$local_dir"
green_message "GitHub Repository:" "$repo_name"
confirm_proceed

# Moves existing local_dir to a numbered backup directory
if [ -d "$backup_dir" ]; then
    count=1
    new_dir="$backup_dir"

    while [ -d "$new_dir" ]; do
        new_dir="$backup_dir$count"
        count=$((count + 1))
    done
    mv -v "$local_dir" "$new_dir"

elif [ -d "$local_dir" ]; then
    mv -v "$local_dir" "$backup_dir"

fi

git clone "$repo_url" "$local_dir"

# Optionally remove all numbered backup directories
if ask_for_confirmation "Remove ${local_dir}_old directory(s)?"; then
    set -- "${local_dir}_old" "${local_dir}_old"*
    case $2 in
        "${local_dir}_old"*) rm -rf "$@" ;;
        *) ;;
    esac
fi

[ "$local_dir" = "$HOME/Documents/linux_docs" ] \
    && run_script "$HOME/Documents/linux_docs/scripts/chmod_scripts.sh"

green_message "Success:" "Cloned repository '$repo_name' into directory '$(basename "$local_dir")'"
