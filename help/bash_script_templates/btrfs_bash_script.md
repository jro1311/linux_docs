#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for btrfs partitions
if mount | grep -q "type btrfs "; then
    echo "btrfs detected"
else
    echo "btrfs not detected"
fi

# Prints a conclusive message
echo "x is now installed"
