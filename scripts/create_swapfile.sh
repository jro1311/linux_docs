#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Define init system
if ps -p 1 -o comm= | grep -q "systemd"; then
    init_system="systemd"
    echo "${green}Detected Init System: $init_system ${reset}"

elif ps -p 1 -o comm= | grep -q "runit"; then
    init_system="runit"
    echo "${green}Detected Init System: $init_system ${reset}"

else
    init_system="unknown"
fi



# Checks for swapfile
if [ ! -f /swapfile ]; then

    # Prompts the user for input
    read -rp "Enter size for swapfile [GiB]: " number

    # Checks that value is a positive number
    if [[ ! "$number" =~ ^[0-9]+$ ]]; then
        echo "${red}Value is not valid ${reset}"
        echo "${red}Enter a positive number ${reset}"
        exit 1
    fi

    # Checks that value is within limits
    if [ "$number" -gt 32 ]; then
        echo "${red}Value is too large ${reset}"
        echo "${red}Maximum allowed swapfile size is 32 GiB ${reset}"
        exit 1
    fi

    echo "${green}Swapfile size set to $number GiB ${reset}"

    # Define file system of root partition
    root_filesystem="$(df -T / | awk 'NR==2 {print $2}')"

    # Creates swapfile
    if [ "$root_filesystem" = "btrfs" ]; then
        sudo btrfs subvolume create /swap
        sudo btrfs filesystem mkswapfile --size "${number}g" --uuid clear /swap/swapfile
        sudo swapon /swap/swapfile
        echo '/swap/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab
        sudo swapon --show
    else
        sudo fallocate -l "${number}G" /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
        sudo swapon --show
    fi

    # Checks for zram
    if zramctl /dev/zram* > /dev/null 2>&1; then

        # Function for user input
        get_answer1() {
        while true; do
            read -r -p "Replace zram with zswap? [Y/n]: " answer1
            answer1="${answer1:-y}"
            case "$answer1" in
                [Yy]* ) return 0;;
                [Nn]* ) return 1;;
                * ) echo "Enter a 'y' or 'n'";;
            esac
        done
    }

        # Checks for answer
        if get_answer1; then

            # Checks for init system
            if [ "$init_system" = "systemd" ]; then
                sudo systemctl disable /dev/zram*
                sudo rm -v /etc/systemd/zram-generator.conf
            elif [ "$init_system" = "runit" ]; then
                sudo zramen toss
                sudo sed -i '/zramen/d' /etc/rc.local
            fi

            # Makes directory(s)
            sudo mkdir -pv /etc/sysctl.d

            # Replaces config(s)
            sudo rm -v /etc/sysctl.d/99-zram.conf
            sudo cp -v "$HOME/Documents/linux_docs/configs/packages/99-swap.conf" /etc/sysctl.d/

            # Loads and applies kernel parameter settings
            sudo sysctl -p /etc/sysctl.d/99-swap.conf

            # Runs script to enable zswap
            chmod +x "$HOME/Documents/linux_docs/scripts/enable_zswap.sh"
            "$HOME/Documents/linux_docs/scripts/enable_zswap.sh"
        fi
    fi
else
    echo "${yellow}Swapfile detected ${reset}"
    exit 1
fi

# Prints a conclusive message
echo "${green}Swapfile created ${reset}"
