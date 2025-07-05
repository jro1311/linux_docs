#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for package
if ! command -v smartctl > /dev/null 2>&1; then
    # Checks for package manager
    if command -v apt > /dev/null 2>&1; then
        echo "Detected: apt"
        # Installs package(s)
        sudo apt-get install -y smartmontools
        
    elif command -v dnf > /dev/null 2>&1; then
        echo "Detected: dnf"
        # Installs package(s)
        sudo dnf install -y smartmontools
        
    elif command -v pacman > /dev/null 2>&1; then
        echo "Detected: pacman"
        # Installs package(s)
        sudo pacman -S --needed --noconfirm smartmontools
        
    elif command -v xbps-install > /dev/null 2>&1; then
        echo "Detected: xbps"
        # Installs package(s)
        sudo xbps-install -Sy smartmontools
        
    elif command -v zypper > /dev/null 2>&1; then
        echo "Detected: zypper"
        # Installs package(s)
        zypper in -y smartmontools
        
    elif command -v rpm-ostree > /dev/null 2>&1; then
        echo "Detected: rpm-ostree"
        # Installs package(s)
        sudo rpm-ostree install smartmontools
        echo "Reboot to use package"
        exit 0
        
    else
        echo "Unsupported package manager"
        exit 1
    fi
fi

# Defines the output file path
output_file="$HOME/Documents/linux_docs/documentation/smart_info/$(date +%Y-%m).txt"

# Finds all SMART devices
devices=$(sudo smartctl --scan | awk '{print $1}')

# Exports SMART info for each device
for device in $devices; do
    sudo smartctl -a "$device" | tee -a "$output_file" > /dev/null 2>&1
done

# Set script(s) as executable
chmod +x "$HOME/Documents/linux_docs/scripts/"*.sh

# Define the cron job
cron_job="0 12 28 * * $HOME/Documents/linux_docs/scripts/export_smart_info.sh"

# Check for cron job
if crontab -l | grep -Fq "$cron_job"; then
    echo "Cron job already exists: $cron_job"
else
    # Adds cron job
    (crontab -l; echo "$cron_job") | crontab -
    echo "Cron job added: $cron_job"
fi

# Prints a conclusive message
echo "SMART info has been successfully exported"
