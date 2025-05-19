#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Exports smart info
sudo smartctl -a /dev/nvme0  > $HOME/Documents/linux_docs/documentation/smart_info/$(date +%Y-%m).txt
sudo smartctl -a /dev/sda  >> $HOME/Documents/linux_docs/documentation/smart_info/$(date +%Y-%m).txt
sudo smartctl -a /dev/sdb  >> $HOME/Documents/linux_docs/documentation/smart_info/$(date +%Y-%m).txt

# Prints a conclusive message to end the script
echo "SMART info has been successfully exported."
