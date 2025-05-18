#!/bin/bash

# Ensures that scripts exit immediately when any error occurs, and it treats unset variables and pipeline failures as errors
set -euo pipefail

# Installs Brave
curl -fsS https://dl.brave.com/install.sh | sh

# Prints a conclusive message to end the script
echo "Brave is now installed."

