#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

ld_bash_dir="$HOME/Documents/linux_docs/configs/system/bash/bash.d"

shopt -s nullglob globstar
for file in "$ld_bash_dir"/**/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done
shopt -u nullglob globstar

if ! ensure_pkg "git"; then
    red_message "Error:" "Could not ensure package(s)."
    exit 1
fi

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

if ! curl -sIf "$repo_url" >/dev/null 2>&1; then
    red_message "Error:" "Failed to reach '$repo_url'"
    exit 1
fi

repo_name=$(basename "$repo_url" .git)

green_message "Local Directory:" "$local_dir"
green_message "GitHub Repository:" "$repo_name"
confirm_proceed

backup_dir "$local_dir"

git clone "$repo_url" "$local_dir"

if confirm "Remove ${local_dir}_old directory(s)? [y/N]"; then
    cleanup_old_backups "$local_dir"
fi

if [ "$local_dir" = "$HOME/Documents/linux_docs" ]; then
    run_script "$LD_SCR/misc/chmod_scripts.sh"
fi

green_message "Success:" "Cloned repository '$repo_name' into directory '$(basename "$local_dir")'"
