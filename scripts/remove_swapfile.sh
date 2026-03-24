#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
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

## Define primary and secondary package managers
primary_package_manager="unknown"
primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)

for cmd in "${primary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        primary_package_manager="$cmd"
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
    green_message "Init System: $init_system"
fi

# Define bootloader
bootloader="unknown"
update_bootloader="unknown"

if command -v update-grub >/dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="update-grub"

elif command -v grub2-mkconfig >/dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub2-mkconfig -o /boot/grub2/grub.cfg"

elif command -v grub-mkconfig >/dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub-mkconfig -o /boot/grub/grub.cfg"

elif command -v limine-update >/dev/null 2>&1; then
    bootloader="limine"
    update_bootloader="limine-update"

elif find /boot/efi/EFI -name "*systemd-boot*.efi" >/dev/null 2>&1; then
    bootloader="systemd-boot"
    update_bootloader="bootctl update"
fi

if [ "$bootloader" != "unknown" ]; then
    echo "${green}Bootloader: $bootloader ${reset}"
fi

# Define file system of root directory
root_filesystem="$(df -T / | awk 'NR==2 {print $2}')"
echo "${green}Root File System: $root_filesystem ${reset}"

ask_for_confirmation() {
    local prompt="$1"
    local answer

    while true; do
        read -r -p "$prompt [Y/n]: " answer
        answer="${answer:-y}"

        case "$answer" in
            [Yy]) return 0 ;;
            [Nn]) return 1 ;;
            *) echo "Enter a 'y' or 'n'." ;;
        esac
    done
}

replace_zswap_with_zram() {
    packages=("zram-generator")

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
    esac

    sudo mkdir -pv /etc/sysctl.d
    sudo cp -v "$HOME/Documents/linux_docs/configs/system/zram/99-zram.conf" /etc/sysctl.d/

    case "$init_system" in
        "systemd")
            sudo cp -v "$HOME/Documents/linux_docs/configs/system/zram/zram-generator.conf" /etc/systemd/

            # Changes compression algorithm from zstd to lz4 on laptops
            if [ "$host_system" = "laptop" ]; then
                sudo sed -i 's/zstd/lz4/g' /etc/systemd/zram-generator.conf
            fi

            # Reloads systemd manager configuration and starts zram device
            sudo systemctl daemon-reload
            sudo systemctl start systemd-zram-setup@zram0.service
            ;;
        "dinit"|"openrc"|"runit"|"s6"|"sysvinit")
            if zramctl /dev/zram* >/dev/null 2>&1; then
                sudo zramen toss
            fi

            # Creates zram swap device with same size as RAM
            algo="unknown"
            size="100"
            if [ "$host_system" = "laptop" ]; then
                algo="lz4"
            else
                algo="zstd"
            fi

            sudo zramen make -a "$algo" -s "$size"

            # Adds command(s) to boot sequence
            sudo touch /etc/rc.local
            if ! grep -Fq "zramen" /etc/rc.local; then
                echo "zramen make -a $algo -s $size" | sudo tee -a /etc/rc.local
            fi
            ;;
        *)
            echo "${red}Unsupported init system: $init_system ${reset}"
            exit 1
            ;;
    esac

    # Reads and applies kernel parameter settings
    sudo sysctl -p /etc/sysctl.d/99-zram.conf

    # Kernel parameter(s)
    zswap_kargs="zswap.enabled=1 zswap.shrinker_enabled=1 zswap.max_pool_percent=25 zswap.compressor=zstd zswap.zpool=zsmalloc zswap.accept_threshold_percent=90"

    # Adds kernel parameter(s)
    case "$primary_package_manager" in
        "rpm-ostree")
            if rpm-ostree kargs | grep -Fq "$zswap_kargs"; then
                sudo rpm-ostree kargs --delete="$zswap_kargs"
                echo "${green}'$zswap_kargs' removed from kernel parameters. ${reset}"
            else
                echo "${green}'$zswap_kargs' not part of kernel parameters. ${reset}"
            fi
            ;;
        *)
            case "$bootloader" in
                "grub")
                    if grep -Fq "$zswap_kargs" /etc/default/grub; then
                        sed -i "s/$zswap_kargs//g" /etc/default/grub;
                        sudo bash -c "$update_bootloader"
                        echo "${green}'$zswap_kargs' removed from kernel parameters. ${reset}"
                    else
                        echo "${green}'$zswap_kargs' not part of kernel parameters. ${reset}"
                    fi
                    ;;
                "limine")
                    if grep -Fq "$zswap_kargs" /etc/default/limine; then
                        sed -i "s/$zswap_kargs//g" /etc/default/limine;
                        sudo bash -c "$update_bootloader"
                        echo "${green}'$zswap_kargs' removed from kernel parameters. ${reset}"
                    else
                        echo "${green}'$zswap_kargs' not part of kernel parameters. ${reset}"
                    fi
                    ;;
            esac
            ;;
    esac
}

# Removes detected swapfile
if [ -f /swapfile ]; then
    sudo swapoff /swapfile
    sudo rm -v /swapfile
    sudo sed -i '/\/swapfile/d' /etc/fstab

elif [ -f /swap/swapfile ]; then
    sudo swapoff /swap/swapfile
    sudo rm -v /swap/swapfile
    sudo sed -i '/\/swap\/swapfile/d' /etc/fstab

    if [ "$root_filesystem" = "btrfs" ]; then
        sudo btrfs subvolume delete /swap
    fi

elif [ -f /swap.img ]; then
    sudo swapoff /swap.img
    sudo rm -v /swap.img
    sudo sed -i '/\/swap.img/d' /etc/fstab

else
    echo "${yellow}No swapfile detected. ${reset}"
    exit 1
fi

# Prompts the user to replace zswap with zram
if ! zramctl /dev/zram* >/dev/null 2>&1; then
    if ask_for_confirmation "Replace zswap with zram?"; then
        replace_zswap_with_zram
    fi
fi

echo "${green}Swapfile removed. ${reset}"
