#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

packages=("rsync")
if ! command -v rsync >/dev/null 2>&1; then

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

mkdir -pv "$HOME/.bashrc.d"

# shellcheck disable=SC2016
if ! grep -Fq '# Sources all .sh files in $HOME/.bashrc.d' "$HOME/.bashrc"; then
    cat "$HOME/Documents/linux_docs/configs/system/bash/bashrc" >> "$HOME/.bashrc"
    echo "${green}Enabled recursive sourcing in $HOME/.bashrc.d ${reset}"
fi

# Define source and destination directory
source_dir="$HOME/Documents/linux_docs/configs/system/bash/bashrc.d/"
destination_dir="$HOME/.bashrc.d/"

# Syncs the source with the destination and checks if it was successful
if rsync -auhvP --delete "$source_dir" "$destination_dir"; then
    echo "${green}Success: '$source_dir' synced with '$destination_dir' ${reset}"
else
    echo "${red}Error: '$source_dir' failed to sync with '$destination_dir' ${reset}"
    exit 1
fi
