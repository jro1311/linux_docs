#!/bin/bash

# Ensures that scripts exit immediately when any error occurs, and it treats unset variables and pipeline failures as errors
set -euo pipefail

# Set all bash scripts in linux_docs directory as executable
chmod +x $HOME/Documents/linux_docs/scripts/*.sh
chmod +x $HOME/Documents/linux_docs/scripts/distros/*.sh
chmod +x $HOME/Documents/linux_docs/scripts/distros/general/*.sh
chmod +x $HOME/Documents/linux_docs/scripts/distros/zach/*.sh
chmod +x $HOME/Documents/linux_docs/scripts/packages/customization/*.sh
chmod +x $HOME/Documents/linux_docs/scripts/packages/graphical/*.sh
chmod +x $HOME/Documents/linux_docs/scripts/packages/terminal/*.sh

# Prints a conclusive message to end the script
echo "All bash scripts are now executable."
