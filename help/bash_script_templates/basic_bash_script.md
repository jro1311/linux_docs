#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s)
sudo apt-get install -y package-name

# Prints a conclusive message
echo "x is now installed"
read -p "Press enter to exit"
