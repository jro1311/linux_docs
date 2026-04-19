#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Defines color variables using tput
if command -v tput &>/dev/null; then
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    yellow=$(tput setaf 3)
    blue=$(tput setaf 4)
    reset=$(tput sgr0)
else
    # Fallback for systems without tput
    red=$'\033[31m'
    green=$'\033[32m'
    yellow=$'\033[33m'
    blue=$'\033[34m'
    reset=$'\033[0m'
fi

# Define file system of root directory
root_fs="$(df -T / | awk 'NR==2 {print $2}')"
echo "${green}Root File System:${reset} $root_fs"

# Define file system of home directory
home_fs="$(df -T /home | awk 'NR==2 {print $2}')"
echo "${green}Home File System:${reset} $home_fs"

file_systems=(bcachefs btrfs ext4 f2fs xfs apfs exfat ntfs vfat zfs)
detected_msgs=()
not_detected_msgs=()

for file_system in "${file_systems[@]}"; do
    if mount | grep -Fq "type $file_system"; then
        detected_msgs+=("${green}Detected:${reset} $file_system partition(s)")
    else
        not_detected_msgs+=("${yellow}Not detected:${reset} $file_system partition(s)")
    fi
done

# Prints detected partitions first
for msg in "${detected_msgs[@]}"; do
    echo "$msg"
done

for msg in "${not_detected_msgs[@]}"; do
    echo "$msg"
done

if mount | grep -Fq "type btrfs"; then
    echo "${green}Detected:${reset} btrfs partition(s)"
else
    echo "${yellow}Not detected:${reset} btrfs partition(s)"
fi
