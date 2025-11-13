#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
green=$(tput setaf 2)
reset=$(tput sgr0)

# Deletes old bashrc settings
sed -i '/^# Custom Settings/,/^# END/d' "$HOME/.bashrc"

# Adds custom bashrc settings
cat "$HOME/Documents/linux_docs/configs/packages/bashrc" >> "$HOME/.bashrc"

# Prints a conclusive message
echo "${green}Updated: $HOME/.bashrc ${reset}"
