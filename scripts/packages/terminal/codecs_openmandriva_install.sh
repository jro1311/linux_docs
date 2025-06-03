#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s)
sudo dnf upgrade -y && sudo dnf install -y faac flac lib64dca0 lib64dvdcss2 lib64xvid4 x264 x265

# Prints a conclusive message to end the script
echo "Multimedia codecs are now installed."
