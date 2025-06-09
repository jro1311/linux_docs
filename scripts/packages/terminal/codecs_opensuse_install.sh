#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s)
sudo zypper ref && sudo zypper dup -y && sudo zypper in -y opi
    
# Installs package(s)
opi codecs

# Prints a conclusive message
echo "Multimedia codecs are now installed"
read -p "Press enter to exit"
