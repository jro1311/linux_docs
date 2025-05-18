#!/bin/bash

# Ensures that scripts exit immediately when any error occurs, and it treats unset variables and pipeline failures as errors
set -euo pipefail

# Installs package(s)
sudo zypper ref && sudo zypper -y dup && sudo zypper in -y opi
    
# Installs package(s)
opi codecs

# Prints a conclusive message to end the script
echo "Multimedia codecs are now installed."
