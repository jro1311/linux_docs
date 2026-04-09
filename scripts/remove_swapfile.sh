#!/usr/bin/env bash
# shellcheck disable=SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc
shopt -u globstar nullglob

detect_system

print_field "Primary Package Manager" "$primary_pm"
print_field "Init System" "$init_system"
print_field "Root File System" "$root_fs"

if [ "$battery_detected" -eq 1 ]; then
    print_field "Detected" "Battery"
fi

if [ "$swap_detected" -eq 0 ]; then
    yellow_message "Not detected:" "Swapfile"
    exit 1
fi

read -r -p "Press ${green}enter${reset} to proceed, or ${red}ctrl+c${reset} to cancel: "
sudo swapoff "$swap_path"
sudo rm -v "$swap_path"
sudo sed -i "\|$fstab_pattern|d" /etc/fstab

if sudo btrfs subvolume show /swap >/dev/null 2>&1; then
    sudo btrfs subvolume delete /swap
fi

# Prompts the user to disable zswap
if grep -Fq "Y" /sys/module/zswap/parameters/enabled; then
    if ask_for_confirmation "Disable zswap and install zram?"; then
        disable_zswap
        install_zram
    fi
fi

green_message "Success:" "Swapfile removed."
