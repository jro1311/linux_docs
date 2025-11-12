#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for btrfs partitions
if mount | grep -Fq "type btrfs"; then
    echo "${green}Detected File System: btrfs ${reset}"
else
    echo "${red}No btrfs partitions detected. ${reset}"
    exit 1
fi

# Checks for init system
if ps -p 1 -o comm= | grep -Fq "systemd"; then
    echo "${green}Detected Init System: systemd ${reset}"
else
    echo "${red}Unsupported init system. ${reset}"
    exit 1
fi

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

if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    echo "${green}Primary Package Manager: $primary_package_manager ${reset}"
fi

if [ "$secondary_package_manager" != "unknown" ]; then
    echo "${green}Secondary Package Manager: $secondary_package_manager ${reset}"
fi

# List of packages
packages=("btrfsmaintenance")

# Checks for package manager and installs package(s)
case "$primary_package_manager" in
    "apt")
        sudo apt-get install -y "${packages[@]}"
        ;;

    "dnf")
        sudo dnf install -y "${packages[@]}"
        ;;

    "pacman")
        # Checks for Chaotic AUR
        if ! grep -Fq "chaotic" /etc/pacman.conf; then
            sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
            sudo pacman-key --lsign-key 3056513887B78AEB
            sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
            sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
            sudo tee -a /etc/pacman.conf <<-'EOF'
            [chaotic-aur]
                Include = /etc/pacman.d/chaotic-mirrorlist

EOF
            echo "${green}Enabled: Chaotic AUR ${reset}"
        fi

        if [[ "$secondary_package_manager" =~ ^(paru|yay)$ ]]; then
            "$secondary_package_manager" -S --needed --noconfirm "${packages[@]}"
        else
            sudo pacman -S --needed --noconfirm base-devel git makepkg
            git clone https://aur.archlinux.org/paru.git
            cd paru
            makepkg -si --noconfirm
            cd ..
            rm -rf paru
            paru -S --needed --noconfirm "${packages[@]}"
        fi
        ;;

    "zypper")
        sudo zypper in -y "${packages[@]}"
        ;;

    "rpm-ostree")
        if ! command -v "${packages[@]}" >/dev/null 2>&1; then
            sudo rpm-ostree install "${packages[@]}"
            echo "${yellow}Reboot and run script again to complete. ${reset}"
            exit 0
        fi
        ;;

    *)
        echo "${red}Unsupported package manager. ${reset}"
        exit 1
        ;;
esac

# Checks for package unit file and then configures systemd timers and paths
if systemctl list-unit-files | grep -Fq "btrfsmaintenance"; then

    sudo systemctl disable btrfs-defrag.timer
    sudo systemctl disable btrfs-trim.timer
    sudo systemctl enable btrfs-balance.timer
    sudo systemctl enable btrfs-scrub.timer
    sudo systemctl enable btrfsmaintenance-refresh.path

fi

# Prints a conclusive message
echo "${green}btrfsmaintenance is now installed. ${reset}"
