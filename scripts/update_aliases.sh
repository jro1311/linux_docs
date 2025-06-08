#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Deletes current aliases
sed -i '/^# Custom Aliases/,${/^# Custom Aliases/d; d;}' "$HOME"/.bashrc

# Detects the operating system and stores it in a variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "Unknown operating system"
    read -p "Press enter to continue"
    exit 1
fi

# Converts the variable into lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Prints the detected operating system
echo "Detected (ID): $os"
echo "Detected (ID_LIKE): $os_like"

# Installs packages based on the detected operating system
case "$os" in
    "arch")
        # Updates aliases
        cat "$HOME/Documents/linux_docs/configs/aliases/pacman_aliases.txt" >> "$HOME"/.bashrc
        ;;
    "debian"|"linuxmint"|"ubuntu")
        # Updates aliases
        cat "$HOME/Documents/linux_docs/configs/aliases/apt_aliases.txt" >> "$HOME"/.bashrc
        ;;
    "fedora")
        # Updates aliases
        cat "$HOME/Documents/linux_docs/configs/aliases/dnf_aliases.txt" >> "$HOME"/.bashrc
        ;;
    "opensuse")
        # Updates aliases
        cat "$HOME/Documents/linux_docs/configs/aliases/zypper_aliases.txt" >> "$HOME"/.bashrc
        ;;
    *)
        case "$os_like" in
            "arch")
                # Updates aliases
                cat "$HOME/Documents/linux_docs/configs/aliases/pacman_aliases.txt" >> "$HOME"/.bashrc
                ;;
            "debian"|"ubuntu debian")
                # Updates aliases
                cat "$HOME/Documents/linux_docs/configs/aliases/apt_aliases.txt" >> "$HOME"/.bashrc
                ;;
            "fedora")
                # Updates aliases
                cat "$HOME/Documents/linux_docs/configs/aliases/dnf_aliases.txt" >> "$HOME"/.bashrc
                ;;
            "opensuse")
                # Updates aliases
                cat "$HOME/Documents/linux_docs/configs/aliases/zypper_aliases.txt" >> "$HOME"/.bashrc
                ;;
            *)
                echo "Unsupported operating system"
                read -p "Press enter to exit"
                exit 1
                ;;
        esac
        ;;
esac

# Prints a conclusive message
echo "Aliases have been updated"
read -p "Press enter to exit"
