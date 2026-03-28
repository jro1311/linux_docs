#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f $rc ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob
shopt -s nullglob

# Detect host system
host_system="unknown"
batteries=(/sys/class/power_supply/BAT*)

if (( ${#batteries[@]} )); then
    host_system="laptop"
else
    host_system="desktop"
fi

if [ "$host_system" != "unknown" ]; then
    green_message "Host System: $host_system"
fi

# Disable nullglob
shopt -u nullglob

# Detect host system
host_system="unknown"
batteries=(/sys/class/power_supply/BAT*)

if (( ${#batteries[@]} )); then
    host_system="laptop"
else
    host_system="desktop"
fi

if [ "$host_system" != "unknown" ]; then
    green_message "Host System: $host_system"
fi

shopt -u nullglob

# Define package managers
primary_package_manager="unknown"
primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)

for cmd in "${primary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        primary_package_manager="$cmd"
        break
    fi
done

# Normalize xbps-install to xbps
if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    green_message "Primary Package Manager: $primary_package_manager"
fi

# Define init system
init_system="unknown"
pid1_comm=$(ps -p 1 -o comm=)

case "$pid1_comm" in
    "systemd"|"dinit"|"runit")
        init_system="$pid1_comm"
        ;;
    "openrc-init")
        init_system="openrc"
        ;;
    "s6-linux-init")
        init_system="s6"
        ;;
    "init")
        init_system="sysvinit"
        ;;
esac

if [ "$init_system" != "unknown" ]; then
    green_message "Init System: $init_system"
fi

# Define file system of root directory
root_filesystem="$(df -T / | awk 'NR==2 {print $2}')"
green_message "Root File System: $root_filesystem"

# Removes detected swapfile
if [ -f /swapfile ]; then
    sudo swapoff /swapfile
    sudo rm -v /swapfile
    sudo sed -i '/\/swapfile/d' /etc/fstab

elif [ -f /swap/swapfile ]; then
    sudo swapoff /swap/swapfile
    sudo rm -v /swap/swapfile
    sudo sed -i '/\/swap\/swapfile/d' /etc/fstab

    if [ "$root_filesystem" = "btrfs" ]; then
        sudo btrfs subvolume delete /swap
    fi

elif [ -f /swap.img ]; then
    sudo swapoff /swap.img
    sudo rm -v /swap.img
    sudo sed -i '/\/swap.img/d' /etc/fstab

else
    yellow_message "No swapfile detected."
    exit 1
fi

# Prompts the user to disable zswap
if grep -Fq "Y" /sys/module/zswap/parameters/enabled; then
    if ask_for_confirmation "Disable zswap and install zram?"; then
        disable_zswap
        install_zram
    fi
fi

green_message "Swapfile removed."
