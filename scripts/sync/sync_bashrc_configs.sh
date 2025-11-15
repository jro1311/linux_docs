#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

mkdir -pv "$HOME/.bashrc.d"

# shellcheck disable=SC2016
if ! grep -Fq '# Sources all .sh files in $HOME/.bashrc.d' "$HOME/.bashrc"; then
    cat "$HOME/Documents/linux_docs/configs/system/bash/bashrc" >> "$HOME/.bashrc"
    echo "${green}Enabled recursive sourcing in $HOME/.bashrc.d ${reset}"
fi

# Define source and destination directory
source="$HOME/Documents/linux_docs/configs/system/bash/bashrc.d/"
destination="$HOME/.bashrc.d/"

# Syncs the source with the destination and checks if it was successful
if rsync -auhvP --delete "$source" "$destination"; then
    echo "${green}Success: '$source' synced with '$destination' ${reset}"
else
    echo "${red}Error: '$source' failed to sync with '$destination' ${reset}"
fi
