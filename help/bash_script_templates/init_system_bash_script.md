#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for init system
if ps -p 1 -o comm= | grep -q "systemd"; then
    echo "Detected: systemd"
elif ps -p 1 -o comm= | grep -q "runit"; then
    echo "Detected: runit"
elif ps -p 1 -o comm= | grep -q "sysvinit"; then
    echo "Detected: sysvinit"
else
    echo "Unsupported init system"
    read -p "Press enter to exit"
    exit 1
fi

# Prints a conclusive message
echo "x is now installed"
read -p "Press enter to exit"
