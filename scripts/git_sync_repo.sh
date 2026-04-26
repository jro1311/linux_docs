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

ensure_pkg "git"

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
            remote="origin"
            branch="main"
            ;;
        2)
            local_dir=$(input_directory "Enter local directory")

            read -er -p "Enter remote (default: origin): " remote
            read -er -p "Enter branch (default: main): " branch

            remote="${remote:-origin}"
            branch="${branch:-main}"
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

if [ ! -d "$local_dir/.git" ]; then
    red_message "Error:" "'$local_dir/.git' does not exist."
    exit 1
fi

green_message "Local Directory:" "$local_dir"
cd "$local_dir"

if ! git show-ref --verify --quiet "refs/remotes/$remote/$branch"; then
    red_message "Error:" "'$remote/$branch' does not exist."
    exit 1
fi

green_message "Remote Branch:" "$remote/$branch"

confirm_proceed

git fetch "$remote"

if git diff --quiet HEAD "$remote/$branch"; then
    green_message "Already up to date:" "No changes detected."
    exit 0
fi

git diff HEAD "$remote/$branch" || true

# Saves current HEAD as backup-<epoch> and hard-resets to remote ref
if confirm "Accept changes [y/N]"; then
    git branch backup-"$(date +%s)"
    git reset --hard "$remote/$branch"
else
    yellow_message "Skipped:" "No changes were made."
    exit 0
fi

if [ "$local_dir" = "$HOME/Documents/linux_docs" ]; then
    run_script "$HOME/Documents/linux_docs/scripts/chmod_scripts.sh"
fi

green_message "Success:" "Synced '$remote/$branch' -> HEAD (in '$(basename "$local_dir")')"
