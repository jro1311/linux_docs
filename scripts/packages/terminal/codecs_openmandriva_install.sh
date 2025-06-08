#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s)
sudo dnf upgrade -y && sudo dnf install -y faac flac lib64dca0 lib64xvid4 x264 x265

# Checks for optical drive
if [ -e /dev/sr0 ]; then
    echo "Optical drive detected"
    # Installs package(s)
    sudo dnf install -y lib64dvdcss2
else
    echo "No optical drive detected"
fi

# Prints a conclusive message
echo "Multimedia codecs are now installed"
read -p "Press enter to exit"
