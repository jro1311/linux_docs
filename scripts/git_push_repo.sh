#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f $rc ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob

if ! command -v git >/dev/null 2>&1; then

    # Define primary package manager
    primary_package_manager="unknown"
    primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)

    for cmd in "${primary_package_managers[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            primary_package_manager="$cmd"
            break
        fi
    done

    # Normalizes xbps-install to xbps
    if [ "$primary_package_manager" = "xbps-install" ]; then
        primary_package_manager="xbps"
    fi

    if [ "$primary_package_manager" != "unknown" ]; then
        green_message "Primary Package Manager:" "$primary_package_manager"
    fi

    packages=("git")
    install_packages "${packages[@]}"

    if [ "$primary_package_manager" = "rpm-ostree" ]; then
        echo "Reboot to apply changes and run the script again."
        exit 0
    fi

fi

# Define the source directory
source_dir="$HOME/Documents/linux_docs"

# Validates directory
if [ ! -d "$source_dir" ]; then
    red_message "Error:" "'$source_dir' does not exist."
    exit 1
fi

if [ ! -d "$source_dir/.git" ]; then
    red_message "Error:" "'$source_dir/.git' does not exist."
    exit 1
fi

cd "$source_dir"

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

    # Checks if variable is empty
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

# Pushes changes to remote repository
git commit -a -m "$commit_message"
git push origin main

green_message "Git push complete."
