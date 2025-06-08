#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for btrfs partitions
if mount | grep -q "type btrfs"; then
    echo "Detected File System: btrfs"
else
    echo "No btrfs partitions detected"
fi

# Checks for ext partitions
if mount | grep -q "type ext"; then
    echo "Detected File System: ext"
else
    echo "No ext partitions detected"
fi

# Checks for f2fs partitions
if mount | grep -q "type f2fs"; then
    echo "Detected File System: f2fs"
else
    echo "No f2fs partitions detected"
fi

# Checks for ntfs partitions
if mount | grep -q "type ntfs"; then
    echo "Detected File System: ntfs"
else
    echo "No ntfs partitions detected"
fi

# Checks for vfat partitions
if mount | grep -q "type vfat"; then
    echo "Detected File System: vfat"
else
    echo "No vfat partitions detected"
fi

# Checks for xfs partitions
if mount | grep -q "type xfs"; then
    echo "Detected File System: xfs"
else
    echo "No xfs partitions detected"
fi

# Checks for zfs partitions
if mount | grep -q "type zfs"; then
    echo "Detected File System: zfs"
else
    echo "No zfs partitions detected"
fi

# Prints a conclusive message
echo "x is now installed"
read -p "Press enter to exit"
