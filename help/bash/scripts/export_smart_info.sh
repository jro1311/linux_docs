#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for package
if ! command -v smartctl > /dev/null 2>&1; then
    # Detect main package manager
    if command -v apt > /dev/null 2>&1; then
        main_package_manager="apt"
        
    elif command -v dnf > /dev/null 2>&1; then
        main_package_manager="dnf"
        
    elif command -v pacman > /dev/null 2>&1; then
        main_package_manager="pacman"
        
    elif command -v xbps-install > /dev/null 2>&1; then
        main_package_manager="xbps"
        
    elif command -v zypper > /dev/null 2>&1; then
        main_package_manager="zypper"
        
    elif command -v rpm-ostree > /dev/null 2>&1; then
        main_package_manager="rpm-ostree"

    else
        main_package_manager="unknown"
    fi

    # Checks for package manager and installs package(s)
    if [ "$main_package_manager" = "apt" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo apt-get install -y smartmontools
        
    elif [ "$main_package_manager" = "dnf" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo dnf install -y smartmontools
        
    elif [ "$main_package_manager" = "pacman" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo pacman -S --needed --noconfirm smartmontools
        
    elif [ "$main_package_manager" = "xbps" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo xbps-install -Sy smartmontools
        
    elif [ "$main_package_manager" = "zypper" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo zypper in -y smartmontools
        
    elif [ "$main_package_manager" = "rpm-ostree" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo rpm-ostree install smartmontools
        echo "${yellow}Reboot to use package${reset}"
        exit 0
        
    else
        echo "${red}Unsupported package manager${reset}"
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
echo "${green}SMART info has been successfully exported ${reset}"
