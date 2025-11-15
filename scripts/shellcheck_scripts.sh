#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

packages=("shellcheck")
if ! command -v shellcheck >/dev/null 2>&1; then

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

error_found=0

# Recursively checks all .sh files for errors
while IFS= read -r -d '' script; do
    if ! shellcheck -x "$script"; then
        error_found=1
    fi
done < <(find "$HOME/Documents/linux_docs/scripts" -type f -name '*.sh' -print0)

if [ "$error_found" -eq 0 ]; then
    echo "${green}No errors were found in any script. ${reset}"
else
    echo "${red}Errors were found in one or more scripts. ${reset}"
fi

exit "$error_found"
