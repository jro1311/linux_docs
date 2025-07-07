#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Checks for package manager
if ! command -v zypper > /dev/null 2>&1; then
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Installs package(s)
sudo zypper in -y opi && opi codecs

# Prints a conclusive message
echo "${green}Multimedia codecs are now installed ${reset}"

