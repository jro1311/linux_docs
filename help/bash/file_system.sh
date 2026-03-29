#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Define file system of root directory
root_filesystem="$(df -T / | awk 'NR==2 {print $2}')"
echo "${green}Root File System: $root_filesystem ${reset}"

# Define file system of home directory
home_filesystem="$(df -T /home | awk 'NR==2 {print $2}')"
echo "${green}Home File System: $home_filesystem ${reset}"

file_systems=(bcachefs btrfs ext4 f2fs xfs apfs exfat ntfs vfat zfs)
detected_msgs=()
not_detected_msgs=()

for file_system in "${file_systems[@]}"; do
    if mount | grep -Fq "type $file_system"; then
        detected_msgs+=("${green}Detected Partition(s): $file_system ${reset}")
    else
        not_detected_msgs+=("${yellow}No $file_system partition detected. ${reset}")
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
    echo "${green}Detected Partition(s): btrfs ${reset}"
else
    echo "${yellow}No btrfs partitions detected. ${reset}"
fi
