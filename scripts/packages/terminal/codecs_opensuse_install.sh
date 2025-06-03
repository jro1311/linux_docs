#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s)
sudo zypper ref && sudo zypper -y dup && sudo zypper in -y opi
    
# Installs package(s)
opi codecs

# Prints a conclusive message to end the script
echo "Multimedia codecs are now installed."
