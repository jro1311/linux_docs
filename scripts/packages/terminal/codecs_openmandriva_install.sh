#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for package manager
if ! command -v dnf > /dev/null 2>&1; then
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Installs package(s)
sudo dnf install -y faac flac lib64dca0 lib64xvid4 x264 x265

# Checks for optical drive
if [ -e /dev/sr0 ]; then
    echo "${green}Optical drive detected ${reset}"
    # Installs package(s)
    sudo dnf install -y lib64dvdcss lib64dvdnav4 lib64dvdread
else
    echo "${yellow}No optical drive detected ${reset}"
fi

# Prints a conclusive message
echo "${green}Multimedia codecs are now installed ${reset}"

