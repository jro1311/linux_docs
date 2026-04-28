#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

. "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d/helpers/source.sh"
source_all "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d"

ensure_pkg "git"

repo_choice=""
local_dir=""
repo_url=""
remote=""
branch=""

repo_choice=$(select_git_repo)
[ -z "$repo_choice" ] && exit 0

case "$repo_choice" in
    linux_docs)
        local_dir="$HOME/Documents/linux_docs"
        repo_url="https://github.com/jro1311/linux_docs.git"
        remote="origin"
        branch="main"
        ;;
    custom)
        local_dir=$(input_directory "Enter local directory")

        read -r -p "Enter GitHub repository URL: " repo_url
        read -r -p "Enter remote (default: origin): " remote
        read -r -p "Enter branch (default: main): " branch

        remote="${remote:-origin}"
        branch="${branch:-main}"
        ;;
esac

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

    mv "$local_dir" "$new_dir"

elif [ -d "$local_dir" ]; then
    mv "$local_dir" "$backup_dir"

fi

git clone "$repo_url" "$local_dir"

# Optionally remove all backup directories
if confirm "Remove ${local_dir}_old directory(s)? [y/N]"; then
    set -- "${local_dir}_old" "${local_dir}_old"*

    case $2 in
        "${local_dir}_old"*) rm -rf "$@" ;;
        *) ;;
    esac
fi

[ "$local_dir" = "$HOME/Documents/linux_docs" ] \
    && run_script "$HOME/Documents/linux_docs/scripts/chmod_scripts.sh"

green_message "Success:" "Cloned repository '$repo_name' into directory '$(basename "$local_dir")'"
