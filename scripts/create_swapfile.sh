#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

host_system="unknown"
primary_package_manager="unknown"
init_system="unknown"
root_filesystem="unknown"

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob

print_field "Host System" "$host_system"
print_field "Primary Package Manager" "$primary_package_manager"
print_field "Init System" "$init_system"
print_field "Root File System" "$root_filesystem"

remove_zram() {
    declare -A zram_generator=(
        [apt]="systemd-zram-generator"
        [dnf]="zram-generator"
        [eopkg]="zram-generator"
        [pacman]="zram-generator"
        [xbps]="zramen"
        [zypper]="zram-generator"
        [rpm-ostree]="zram-generator"
    )

    check "zramctl" \
        remove_packages "${zram_generator[$primary_package_manager]}"

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
