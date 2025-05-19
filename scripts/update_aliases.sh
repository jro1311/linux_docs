#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Deletes current aliases
sed -i '/^# Custom Aliases/,${/^# Custom Aliases/d; d;}' $HOME/.bashrc

# Detects the operating system and stores it in a variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS="${ID:-unknown}"

    # Fallback to $OS if ID_LIKE is missing
    OS_LIKE="${ID_LIKE:-$OS}"
else
    echo "Unable to detect the operating system"
    exit 1
fi

# Converts the variable into lowercase
OS=$(echo "${OS:-unknown}" | tr '[:upper:]' '[:lower:]')
OS_LIKE=$(echo "$OS_LIKE" | tr '[:upper:]' '[:lower:]')

# Prints the detected operating system
echo "Detected: $OS"

# Installs packages based on the detected operating system
case "$OS" in
    "arch")
        # Update aliases
        cat $HOME/Documents/linux_docs/configs/aliases/aliases_arch.txt >> $HOME/.bashrc
        ;;
    "debian")
        # Update aliases
        cat $HOME/Documents/linux_docs/configs/aliases/aliases_debian.txt >> $HOME/.bashrc
        ;;
    "ubuntu")
        # Update aliases
        cat $HOME/Documents/linux_docs/configs/aliases/aliases_ubuntu.txt >> $HOME/.bashrc
        ;;
    "linuxmint")
        # Update aliases
        cat $HOME/Documents/linux_docs/configs/aliases/aliases_linux_mint.txt >> $HOME/.bashrc
        ;;
    "fedora")
        # Update aliases
        cat $HOME/Documents/linux_docs/configs/aliases/aliases_fedora.txt >> $HOME/.bashrc
        ;;
    "opensuse")
        # Update aliases
        cat $HOME/Documents/linux_docs/configs/aliases/aliases_opensuse.txt >> $HOME/.bashrc
        ;;
    *)
        case "$OS_LIKE" in
            "arch")
                # Update aliases
                cat $HOME/Documents/linux_docs/configs/aliases/aliases_arch.txt >> $HOME/.bashrc
                ;;
            "debian")
                # Update aliases
                cat $HOME/Documents/linux_docs/configs/aliases/aliases_debian.txt >> $HOME/.bashrc
                ;;
            "ubuntu")
                # Update aliases
                cat $HOME/Documents/linux_docs/configs/aliases/aliases_ubuntu.txt >> $HOME/.bashrc
                ;;
            "fedora")
                # Update aliases
                cat $HOME/Documents/linux_docs/configs/aliases/aliases_fedora.txt >> $HOME/.bashrc
                ;;
            "opensuse")
                # Update aliases
                cat $HOME/Documents/linux_docs/configs/aliases/aliases_opensuse.txt >> $HOME/.bashrc
                ;;
            *)
                echo "Unsupported distribution: $OS"
                exit 1
                ;;
        esac
        ;;
esac

# Prints a conclusive message to end the script
echo "Aliases have been updated."
