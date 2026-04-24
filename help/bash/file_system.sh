#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Defines filesystems of / and /home directory
root_fs="$(df -T / | awk 'NR==2 {print $2}')"
home_fs="$(df -T /home | awk 'NR==2 {print $2}')"

echo "${green}Root File System:${reset} $root_fs"
echo "${green}Home File System:${reset} $home_fs"

file_systems=(
    bcachefs
    btrfs
    ext4
    f2fs
    xfs
    apfs
    exfat
    ntfs
    vfat
    zfs
)

fs_detected_list=()

for fs in "${file_systems[@]}"; do
    if mount | grep -Fq "type $fs"; then
        fs_detected_list+=("$fs")
        printf -v "${fs}_detected" 1
    else
        printf -v "${fs}_detected" 0
    fi
done

fs_detected_csv="$(printf '%s, ' "${fs_detected_list[@]}")"
fs_detected_csv="${fs_detected_csv%, }"

echo "${green}Partition(s):${reset}" "$fs_detected_csv"
