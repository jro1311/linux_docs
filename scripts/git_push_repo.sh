#!/usr/bin/env bash

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
packages=("git")
for package in "${packages[@]}"; do
    inverse_check "$package" \
        install_packages "$package"
done

# Define the local directory
read -er -p "Enter local directory (default: ${HOME}/Documents/linux_docs): " local_dir
local_dir=${local_dir:-"$HOME/Documents/linux_docs"}

# Validates directory
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
        green_message "Success:" "SSH key created for $email_address."
        green_message "Add SSH key to GitHub account and run script again to push commits."
        exit 0
    else
        red_message "Error:" "Failed to create SSH key for $email_address."
    fi

fi

# Prompts the user for input
read -er -p "Enter commit message: " commit_message

if [ -z "$commit_message" ]; then
    red_message "Error:" "No commit message."
    exit 1
fi

# Pushes changes to remote repository
git add -A
git commit -m "$commit_message"
git push origin main

green_message "Success:" "Pushed updates to GitHub repository."
