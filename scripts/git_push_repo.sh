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

# Sets email address for git config
if ! git config --global --get user.email >/dev/null 2>&1; then
    read -er -p "Enter email address: " email_address
    git config --global user.email "$email_address"
fi

# Sets username for git config
if ! git config --global --get user.name >/dev/null 2>&1; then
    read -er -p "Enter username: " username
    git config --global user.name "$username"
fi

# Generates SSH key
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then

    if [ -z "$email_address" ]; then
        read -er -p "Enter email address: " email_address
    fi

    if ssh-keygen -t ed25519 -C "$email_address"; then
        green_message "Success:" "SSH key created for '$email_address'."
        green_message "Add SSH key to GitHub account and run script again to push commits."
        exit 0
    else
        red_message "Error:" "Failed to create SSH key for '$email_address'."
    fi

fi

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

git add -A

if git diff --quiet "$remote/$branch"; then
    green_message "Already up to date:" "No changes detected."
    exit 0
fi

read -er -p "Enter commit message: " commit_message

if [ -z "$commit_message" ]; then
    red_message "Error:" "No commit message."
    exit 1
fi

git commit -m "$commit_message"
git push "$remote" "$branch"

green_message "Success:" "Pushed HEAD (from '$(basename "$local_dir")') -> '$remote/$branch'"
