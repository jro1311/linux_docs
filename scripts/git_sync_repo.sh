#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

bashd_dir="$HOME/Documents/linux_docs/configs/system/bash/bashrc.d"

for file in "$bashd_dir"/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done

for dir in helpers configure_packages install_packages; do
    for file in "$bashd_dir/$dir"/*.sh; do
        [ -e "$file" ] || continue
        . "$file"
    done
done

if ! ensure_pkg "git"; then
    red_message "Error:" "Could not ensure package(s)."
    exit 1
fi

repo_choice=""
local_dir=""
remote=""
branch=""

repo_choice=$(select_git_repo)
[ -z "$repo_choice" ] && exit 0

case "$repo_choice" in
    linux_docs)
        local_dir="$HOME/Documents/linux_docs"
        remote="origin"
        branch="main"
        ;;
    custom)
        local_dir=$(input_directory "Enter local directory")

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

git fetch "$remote"

if git diff --quiet HEAD "$remote/$branch"; then
    green_message "Already up to date:" "No changes detected."
    exit 0
fi

git diff HEAD "$remote/$branch" || true

# Saves current HEAD as backup-<epoch> and hard-resets to remote ref
if confirm "Accept changes? [y/N]"; then
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
