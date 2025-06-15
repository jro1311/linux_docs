#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s)
sudo xbps-install -u -y && sudo xbps-install -y faac flac x264 x265

# Checks for optical drive
if [ -e /dev/sr0 ]; then
    echo "Optical drive detected"
    # Installs package(s)
    sudo xbps-install -y lib64dvdcss lib64dvdnav4 lib64dvdread
else
    echo "No optical drive detected"
fi

# Prints a conclusive message
echo "Multimedia codecs are now installed"
read -p "Press enter to exit"
