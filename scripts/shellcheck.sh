#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Detects the operating system and stores it in a variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "Unable to detect the operating system"
    read -p "Press enter to exit"
    exit 1
fi

# Converts the variable into lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Checks for package
if ! command -v shellcheck &> /dev/null; then
    # Prints the detected operating system
    echo "Detected (ID): $os"
    echo "Detected (ID_LIKE): $os_like"

    # Installs package(s) based on the package manager detected
    if command -v apt &> /dev/null; then
        echo "Detected: apt"
        # Installs package(s)
        sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y shellcheck
    elif command -v dnf &> /dev/null; then
        echo "Detected: dnf"
        # Installs package(s)
        sudo dnf upgrade -y && sudo dnf install -y shellcheck
    elif command -v pacman &> /dev/null; then
        echo "Detected: pacman"
        # Installs package(s)
        sudo pacman -Syu --needed --noconfirm shellcheck
    elif command -v rpm-ostree &> /dev/null; then
        echo "Detected: rpm-ostree"
        # Installs package(s)
        sudo rpm-ostree upgrade && sudo rpm-ostree install shellcheck
        echo "Reboot to use package"
        read -p "Press enter to exit"
        exit 0
    elif command -v xbps-install &> /dev/null; then
        echo "Detected: xbps"
        # Installs package(s)
        sudo xbps-install -Su xbps && sudo xbps-install -u && sudo xbps-install -y shellcheck
    elif command -v zypper &> /dev/null; then
        echo "Detected: zypper"
        # Installs package(s)
        if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
            sudo zypper ref && sudo zypper dup -y && sudo zypper in -y shellcheck
        elif [ "$os" = "opensuse-leap" ]; then
            sudo zypper ref && sudo zypper up -y && sudo zypper in -y shellcheck
        else
            echo "Unsupported operating system"
            read -p "Press enter to exit"
            exit 1
        fi
    else
        echo "Unsupported package manager"
        read -p "Press enter to exit"
        exit 1
    fi
fi

# Track if any script fails the syntax check
error_found=0

# Recursively finds all .sh files and checks each for errors
while IFS= read -r -d '' script; do
    if ! shellcheck -x --exclude=2162 "$script" > /dev/null 2>&1; then
        shellcheck -x --exclude=2162 "$script"
        error_found=1
    fi
done < <(find "$HOME/Documents/linux_docs/scripts" -type f -name '*.sh' -print0)

# Prints a conclusive message if no errors were found
if [ "$error_found" -eq 0 ]; then
    echo "No errors were found in any script"
fi
read -p "Press enter to exit"
