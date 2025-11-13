#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Enable nullglob so that the glob expands to nothing if no match
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
    echo "${green}Host System: $host_system ${reset}"
fi

# Disable nullglob
shopt -u nullglob

# Define package managers
primary_package_manager="unknown"
secondary_package_manager="unknown"

primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)
secondary_package_managers=(nala paru yay)

for cmd in "${primary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        primary_package_manager="$cmd"
        break
    fi
done

for cmd in "${secondary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        secondary_package_manager="$cmd"
        break
    fi
done

# Normalizes xbps-install to xbps
if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    echo "${green}Primary Package Manager: $primary_package_manager ${reset}"
fi

if [ "$secondary_package_manager" != "unknown" ]; then
    echo "${green}Secondary Package Manager: $secondary_package_manager ${reset}"
fi

# Define init system
init_system="unknown"
init_names=(systemd runit sysvinit openrc-init)
pid1_comm=$(ps -p 1 -o comm=)

for init_name in "${init_names[@]}"; do
    if [ "$pid1_comm" = "$init_name" ]; then
        init_system="$init_name"
        break
    fi
done

if [ "$init_system" != "unknown" ]; then
    echo "${green}Init System: $init_system ${reset}"
fi

# List of packages
packages=("zram-generator")

# Checks package manager and installs package(s)
case "$primary_package_manager" in
    "apt")
        sudo apt-get install -y systemd-zram-generator
        ;;
    "dnf")
        sudo dnf install -y "${packages[@]}"
        ;;
    "eopkg")
        sudo eopkg install -y "${packages[@]}"
        ;;
    "pacman")
        sudo pacman -S --needed --noconfirm "${packages[@]}"
        ;;
    "xbps")
        sudo xbps-install -Sy zramen
        ;;
    "zypper")
        sudo zypper in -y "${packages[@]}"
        ;;
    "rpm-ostree")
        sudo rpm-ostree install "${packages[@]}"
        ;;
    *)
        echo "${red}Unsupported package manager. ${reset}"
        exit 1
        ;;
esac

# Copies config(s)
sudo mkdir -pv /etc/sysctl.d
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram/99-zram.conf" /etc/sysctl.d/

# Checks init system
case "$init_system" in
    "systemd")
        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram/zram-generator.conf" /etc/systemd/

        # Changes compression algorithm from zstd to lz4 on laptops
        if [ "$host_system" = "laptop" ]; then
            sudo sed -i 's/zstd/lz4/g' /etc/systemd/zram-generator.conf
        fi

        # Reloads systemd manager configuration and starts zram device
        sudo systemctl daemon-reload
        sudo systemctl start systemd-zram-setup@zram0.service
        ;;
    "runit")
        if zramctl /dev/zram* >/dev/null 2>&1; then
            sudo zramen toss
        fi

        # Checks host system and adds zram swap device with same size as RAM
        if [ "$host_system" = "laptop" ]; then
            sudo zramen make -a lz4 -s 100

            # Adds command to boot sequence
            if ! grep -Fq "zramen" /etc/rc.local; then
                echo "zramen make -a lz4 -s 100" | sudo tee -a /etc/rc.local
            fi

        elif [ "$host_system" = "desktop" ]; then
            sudo zramen make -a zstd -s 100

            # Adds command to boot sequence
            if ! grep -Fq "zramen" /etc/rc.local; then
                echo "zramen make -a zstd -s 100" | sudo tee -a /etc/rc.local
            fi

        fi
        ;;
    *)
        echo "${red}Unsupported init system: $init_system ${reset}"
        exit 1
        ;;
esac

# Loads and applies kernel parameter settings
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Prints a conclusive message
echo "${green}zram is now installed. ${reset}"
