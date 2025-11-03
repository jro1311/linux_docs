#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
green=$(tput setaf 2)
reset=$(tput sgr0)

# Deletes old bashrc settings
sed -i '/^# Custom Settings/,${/^# Custom Settings/d; d;}' "$HOME/.bashrc"

# Adds custom bashrc settings
cat "$HOME/Documents/linux_docs/configs/packages/bashrc" >> "$HOME/.bashrc"

# Prints a conclusive message
echo "${green}$HOME/.bashrc has been updated. ${reset}"
