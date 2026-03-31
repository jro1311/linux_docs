#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f $rc ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob
shopt -s nullglob

# Detect host system
host_system="unknown"
batteries=(/sys/class/power_supply/BAT*)

if (( ${#batteries[@]} )); then
    host_system="laptop"
else
    host_system="desktop"
fi

if [ "$host_system" != "unknown" ]; then
    green_message "Host System:" "$host_system"
fi

# Disable nullglob
shopt -u nullglob

# Define package managers
primary_package_manager="unknown"
primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)

for cmd in "${primary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        primary_package_manager="$cmd"
        break
    fi
done

# Normalize xbps-install to xbps
if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    green_message "Primary Package Manager:" "$primary_package_manager"
fi

# Define init system
init_system="unknown"
pid1_comm=$(ps -p 1 -o comm=)

case "$pid1_comm" in
    "systemd"|"dinit"|"runit")
        init_system="$pid1_comm"
        ;;
    "openrc-init")
        init_system="openrc"
        ;;
    "s6-linux-init")
        init_system="s6"
        ;;
    "init")
        init_system="sysvinit"
        ;;
esac

if [ "$init_system" != "unknown" ]; then
    green_message "Init System:" "$init_system"
fi

# Define file system of root directory
root_filesystem="$(df -T / | awk 'NR==2 {print $2}')"
green_message "Root File System:" "$root_filesystem"

remove_zram() {
    declare -A zram_package=(
        [apt]="systemd-zram-generator"
        [dnf]="zram-generator"
        [eopkg]="zram-generator"
        [pacman]="zram-generator"
        [xbps]="zramen"
        [zypper]="zram-generator"
        [rpm-ostree]="zram-generator"
    )

    check "${zram_package[$primary_package_manager]}" remove_packages "${zram_package[$primary_package_manager]}"

    case "$init_system" in
        "systemd")
            if [ -f /etc/systemd/zram-generator.conf ]; then
                sudo rm -v /etc/systemd/zram-generator.conf
            fi

            # Reloads systemd manager configuration
            sudo systemctl daemon-reload
            ;;
        "dinit"|"openrc"|"runit"|"s6"|"sysvinit")
            sudo sed -i '/zramen/d' /etc/rc.local

            if [ -f /etc/modules-load.d/zram.conf ]; then
                sudo rm -v /etc/modules-load.d/zram.conf
            fi

            if [ -f /etc/udev/rules.d/99-zram.rules ]; then
                sudo rm -v /etc/udev/rules.d/99-zram.rules
            fi

            sudo sed -i '/\/dev\/zram0/d' /etc/fstab
    esac

    if [ -f /etc/sysctl.d/99-zram.conf ]; then
        sudo rm -v /etc/sysctl.d/99-zram.conf
    fi

    # Replaces zram meter with swap in htop
    if command -v htop >/dev/null 2>&1; then
        sed -i 's/Zram/Swap/g' "$HOME/.config/htop/htoprc"
    fi
}

# Creates swapfile if one doesn't already exist
if [[ ! -f /swapfile || ! -f /swap/swapfile || -f /swap.img ]]; then
    read -rp "Enter size for swapfile [GiB]: " number

    # Checks that value is a positive number
    if [[ ! "$number" =~ ^[0-9]+$ ]]; then
        red_message "Value is not valid."
        red_message "Enter a positive number."
        exit 1
    fi

    # Checks that value is within limits
    if [ "$number" -gt 32 ]; then
        red_message "Value is too large."
        red_message "Maximum allowed swapfile size is 32 GiB."
        exit 1
    fi

    green_message "Swapfile size set to $number GiB."

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

else
    yellow_message "Swapfile detected."
    exit 1
fi


# Prompts the user to enable zswap
if grep -Fq "N" /sys/module/zswap/parameters/enabled; then
    if ask_for_confirmation "Enable zswap?"; then
        remove_zram
        enable_zswap
    fi
else
    sudo mkdir -pv /etc/sysctl.d
    sudo cp -v "$HOME/Documents/linux_docs/configs/system/99-swap.conf" /etc/sysctl.d/
fi

# Reads and applies kernel parameter settings
sudo sysctl -p /etc/sysctl.d/99-swap.conf

green_message "Swapfile created."
