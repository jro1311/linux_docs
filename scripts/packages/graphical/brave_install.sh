#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs Brave
curl -fsS https://dl.brave.com/install.sh | sh

# Prints a conclusive message
echo "Brave is now installed."

