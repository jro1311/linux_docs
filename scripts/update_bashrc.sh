#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Deletes old settings
sed -i '/^# Custom Settings/,${/^# Custom Settings/d; d;}' "$HOME"/.bashrc

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
        # Updates bashrc
        cat "$HOME/Documents/linux_docs/configs/bash/pacman_bashrc.txt" >> "$HOME"/.bashrc
        ;;
    "debian"|"linuxmint"|"ubuntu")
        # Updates bashrc
        cat "$HOME/Documents/linux_docs/configs/bash/apt_bashrc.txt" >> "$HOME"/.bashrc
        ;;
    "fedora")
        # Updates bashrc
        cat "$HOME/Documents/linux_docs/configs/bash/dnf_bashrc.txt" >> "$HOME"/.bashrc
        ;;
    "opensuse")
        # Updates bashrc
        cat "$HOME/Documents/linux_docs/configs/bash/zypper_bashrc.txt" >> "$HOME"/.bashrc
        ;;
    "void")
        # Updates bashrc
        cat "$HOME/Documents/linux_docs/configs/bash/xbps_bashrc.txt" >> "$HOME"/.bashrc
    *)
        case "$os_like" in
            "arch")
                # Updates bashrc
                cat "$HOME/Documents/linux_docs/configs/bash/pacman_bashrc.txt" >> "$HOME"/.bashrc
                ;;
            "debian"|"ubuntu debian")
                # Updates bashrc
                cat "$HOME/Documents/linux_docs/configs/bash/apt_bashrc.txt" >> "$HOME"/.bashrc
                ;;
            "fedora")
                # Updates bashrc
                cat "$HOME/Documents/linux_docs/configs/bash/dnf_bashrc.txt" >> "$HOME"/.bashrc
                ;;
            "opensuse")
                # Updates bashrc
                cat "$HOME/Documents/linux_docs/configs/bash/zypper_bashrc.txt" >> "$HOME"/.bashrc
                ;;
            "void")
                # Updates bashrc
                cat "$HOME/Documents/linux_docs/configs/bash/xbps_bashrc.txt" >> "$HOME"/.bashrc
            *)
                echo "Unsupported operating system"
                read -p "Press enter to exit"
                exit 1
                ;;
        esac
        ;;
esac

# Prints a conclusive message
echo "bashrc has been updated"
read -p "Press enter to exit"
