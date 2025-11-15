#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

packages=("git")
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
        echo "${green}Primary Package Manager: $primary_package_manager ${reset}"
    fi

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
            if ! command -v "${packages[@]}" >/dev/null 2>&1; then
                sudo rpm-ostree install "${packages[@]}"
                echo "${yellow}Reboot and run script again to complete. ${reset}"
                exit 0
            fi
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

ask_for_confirmation() {
    local prompt="$1"
    local answer

    while true; do
        read -r -p "$prompt [Y/n]: " answer
        answer="${answer:-y}"

        case "$answer" in
            [Yy]) return 0 ;;
            [Nn]) return 1 ;;
            *) echo "Enter a 'y' or 'n'." ;;
        esac
    done
}

# Calls function
if ask_for_confirmation "Remove linux_docs_old directory(s)?"; then
    rm -rf "$HOME/Documents/linux_docs_old"*
fi

# Recursively finds all .sh files and sets them as executable
find "$HOME/Documents/linux_docs/scripts" -type f \
    -name "*.sh" \
    -exec chmod +x {} +

# Print a conclusive message
echo "${green}Git clone complete. ${reset}"
