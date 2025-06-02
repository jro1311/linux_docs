#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Exports smart info without displaying output
sudo smartctl -a /dev/nvme0 | tee "$HOME/Documents/linux_docs/documentation/smart_info/$(date +%Y-%m).txt" > /dev/null 2>&1
sudo smartctl -a /dev/sda  | tee -a "$HOME/Documents/linux_docs/documentation/smart_info/$(date +%Y-%m).txt" > /dev/null 2>&1
sudo smartctl -a /dev/sdb | tee -a "$HOME/Documents/linux_docs/documentation/smart_info/$(date +%Y-%m).txt" > /dev/null 2>&1

# Prints a conclusive message to end the script
echo "SMART info has been successfully exported."
