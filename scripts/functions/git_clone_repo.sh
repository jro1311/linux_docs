#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# List of packages
packages=("git")

# Checks for package
if ! command -v git > /dev/null 2>&1; then

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
        echo "${green}Primary Package Manager: $primary_package_manager ${reset}"
    fi

    # Checks for package manager and installs package(s)
    case $primary_package_manager in
        "apt")
            sudo apt-get install -y "${packages[@]}"
            ;;
        "dnf")
            sudo dnf install -y "${packages[@]}"
            ;;
        "eopkg")
            sudo eopkg install -y "${packages[@]}"
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm "${packages[@]}"
            ;;
        "xbps")
            sudo xbps-install -Sy "${packages[@]}"
            ;;
        "zypper")
            sudo zypper in -y "${packages[@]}"
            ;;
        "rpm-ostree")
            sudo rpm-ostree install "${packages[@]}"
            echo "${yellow}Reboot and run script again to complete. ${reset}"
            exit 0
            ;;
        *)
            echo "${red}Unsupported package manager. ${reset}"
            exit 1
            ;;
    esac
fi

# Define the source/base directories and the github repository
source_dir="$HOME/Documents/linux_docs"
base_dir="$HOME/Documents/linux_docs_old"
repo_url="https://github.com/jro1311/linux_docs.git"

# Checks for directory
if [ -d "$base_dir" ]; then

    # Use numbered naming logic
    count=1
    new_dir="$base_dir"

    while [ -d "$new_dir" ]; do

        new_dir="$base_dir$count"
        count=$((count + 1))

    done

    # Renames directory(s)
    mv -v "$source_dir" "$new_dir"

elif [ -d "$source_dir" ]; then

    # Renames directory(s)
    mv -v "$source_dir" "$base_dir"

fi

# Clones git repository
git clone "$repo_url" "$source_dir"

# Enable nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Function for user input
remove_old_directories() {
    while true; do
        read -r -p "Remove linux_docs_old directory(s)? [Y/n]: " answer
        answer="${answer:-y}"

        case "$answer" in
            [Yy])
                return 0
                ;;
            [Nn])
                return 1
                ;;
            *)
                echo "Enter a 'y' or 'n'."
                ;;
        esac
    done
}

# Checks for answer
if remove_old_directories; then
    rm -rf "$HOME/Documents/linux_docs_old"*
fi

# Runs script to make all scripts executable
chmod +x "$HOME/Documents/linux_docs/scripts/functions/chmod_scripts.sh"
"$HOME/Documents/linux_docs/scripts/functions/chmod_scripts.sh"

# Print a conclusive message
echo "${green}Git clone complete. ${reset}"
