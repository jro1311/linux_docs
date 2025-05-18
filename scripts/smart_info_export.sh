#!/bin/bash

# Ensures that scripts exit immediately when any error occurs, and it treats unset variables and pipeline failures as errors
set -euo pipefail

# Exports smart info
sudo smartctl -a /dev/nvme0  > $HOME/Documents/linux_docs/documentation/smart_info/$(date +%Y-%m).md
sudo smartctl -a /dev/sda  >> $HOME/Documents/linux_docs/documentation/smart_info/$(date +%Y-%m).md
sudo smartctl -a /dev/sdb  >> $HOME/Documents/linux_docs/documentation/smart_info/$(date +%Y-%m).md

# Prints a conclusive message to end the script
echo "SMART info has been successfully exported."
