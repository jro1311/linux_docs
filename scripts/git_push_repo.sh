#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

ld_bash_dir="$HOME/Documents/linux_docs/configs/system/bash/bash.d"

for file in "$ld_bash_dir"/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done

for dir in helpers configure_packages install_packages; do
    for file in "$ld_bash_dir/$dir"/*.sh; do
        [ -e "$file" ] || continue
        . "$file"
    done
done

if ! ensure_pkg "git"; then
    red_message "Error:" "Could not ensure package(s)."
    exit 1
fi

# Sets email address for git config
if ! git config --global --get user.email >/dev/null 2>&1; then
    read -r -p "Enter email address: " email_address
    git config --global user.email "$email_address"
fi

# Sets username for git config
if ! git config --global --get user.name >/dev/null 2>&1; then
    read -r -p "Enter username: " username
    git config --global user.name "$username"
fi

# Generates SSH key
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then

    if [ -z "$email_address" ]; then
        read -r -p "Enter email address: " email_address
    fi

    if ssh-keygen -t ed25519 -C "$email_address"; then
        green_message "Success:" "SSH key created for '$email_address'."
        green_message "Add SSH key to GitHub account and run script again to push commits."
        exit 0
    else
        red_message "Error:" "Failed to create SSH key for '$email_address'."
    fi

fi

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

confirm_proceed

git add -A

if ! git symbolic-ref -q HEAD >/dev/null; then
    red_message "Error:" "HEAD is detached. Checkout a branch before committing."
    exit 1
fi

uncommitted=0
unpushed=0

git diff --quiet || uncommitted=1
git diff --cached --quiet || uncommitted=1

git fetch "$remote" "$branch"
git diff --quiet HEAD "$remote/$branch" || unpushed=1

if [ "$uncommitted" -eq 0 ] && [ "$unpushed" -eq 0 ]; then
    green_message "Already up to date:" "No changes detected."
    exit 0
fi

read -r -p "Enter commit message: " commit_message

if [ -z "$commit_message" ]; then
    red_message "Error:" "No commit message."
    exit 1
fi

git commit -m "$commit_message"
git push "$remote" "$branch"

green_message "Success:" "Pushed HEAD (from '$(basename "$local_dir")') -> '$remote/$branch'"
