#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for package manager
if ! command -v zypper > /dev/null 2>&1; then
    echo "Unsupported package manager"
    exit 1
fi

# Checks for zypper
if command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    # Installs package(s)
    sudo zypper in -y opi && opi codecs
fi

# Prints a conclusive message
echo "Multimedia codecs are now installed"

