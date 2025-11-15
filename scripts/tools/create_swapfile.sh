#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

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

replace_zram_with_zswap() {
    packages=("zram-generator")
    case "$init_system" in
        "systemd")
            case "$primary_package_manager" in
                "apt")
                    sudo apt-get remove -y systemd-zram-generator
                    ;;
                "dnf")
                    sudo dnf remove -y "${packages[@]}"
                    ;;
                "eopkg")
                    sudo eopkg remove -y "${packages[@]}"
                    ;;
                "pacman")
                    sudo pacman -Rs --noconfirm "${packages[@]}"
                    ;;
                "zypper")
                    sudo zypper rm --clean-deps -y "${packages[@]}"
                    ;;
                "rpm-ostree")
                    sudo rpm-ostree remove "${packages[@]}"
                    ;;
            esac

            sudo rm -v /etc/systemd/zram-generator.conf

            # Reloads systemd manager configuration
            sudo systemctl daemon-reload
            ;;
        "runit")
            # Removes zram swap devices if present
            if zramctl /dev/zram* >/dev/null 2>&1; then
                sudo zramen toss
            fi

            # Removes boot sequence command(s)
            sudo sed -i '/zramen/d' /etc/rc.local

            case "$primary_package_manager" in
                "xbps")
                    sudo xbps-remove -Ry zramen
                    ;;
            esac
            ;;
    esac

    sudo mkdir -pv /etc/sysctl.d
    sudo rm -v /etc/sysctl.d/99-zram.conf
    sudo cp -v "$HOME/Documents/linux_docs/configs/system/99-swap.conf" /etc/sysctl.d/

    # Reads and applies kernel parameter settings
    sudo sysctl -p /etc/sysctl.d/99-swap.conf

    # Kernel argument(s)
    zswap_karg="zswap.enabled=1"

    # Adds kernel argument(s)
    case "$primary_package_manager" in
        "rpm-ostree")
            if ! rpm-ostree kargs | grep -Fq "$zswap_karg"; then
                sudo rpm-ostree kargs --append=preempt=lazy
                echo "${green}'Added $zswap_karg' to kernel arguments. ${reset}"

            else
                echo "${green}'$zswap_karg' is already part of kernel arguments. ${reset}"
            fi
            ;;
        *)
            case "$bootloader" in
                "grub")
                    if ! grep -Fq "$zswap_karg" /etc/default/grub; then
                        sudo sed -i "s/\(GRUB_CMDLINE_LINUX=\"[^\"]*\)\"/\1 $zswap_karg\"/" /etc/default/grub
                        sudo bash -c "$update_bootloader"
                        echo "${green}Added '$zswap_karg' to kernel arguments. ${reset}"

                    else
                        echo "${green}'$zswap_karg' is already part of kernel arguments. ${reset}"
                    fi
                    ;;
                "limine")
                    if ! grep -Fq "$zswap_karg" /etc/default/limine; then
                        sudo sed -i "/^KERNEL_CMDLINE\[default\\]/ s/\"$/ $zswap_karg\"/" /etc/default/limine
                        sudo bash -c "$update_bootloader"
                        echo "${green}Added '$zswap_karg' to kernel arguments. ${reset}"

                    else
                        echo "${green}'$zswap_karg' is already part of kernel arguments. ${reset}"
                    fi
                    ;;
            esac
            ;;
    esac
}

# Creates swapfile if one doesn't already exist
if [[ ! -f /swapfile || ! -f /swap/swapfile || -f /swap.img ]]; then
    read -rp "Enter size for swapfile [GiB]: " number

    # Checks that value is a positive number
    if [[ ! "$number" =~ ^[0-9]+$ ]]; then
        echo "${red}Value is not valid. ${reset}"
        echo "${red}Enter a positive number. ${reset}"
        exit 1
    fi

    # Checks that value is within limits
    if [ "$number" -gt 32 ]; then
        echo "${red}Value is too large. ${reset}"
        echo "${red}Maximum allowed swapfile size is 32 GiB. ${reset}"
        exit 1
    fi

    echo "${green}Swapfile size set to $number GiB. ${reset}"

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

    # Detects zram device and prompts the user to replace zram with zswap
    if zramctl /dev/zram* >/dev/null 2>&1; then
        if ask_for_confirmation "Replace zram with zswap?"; then
            replace_zram_with_zswap
        fi
    fi
else
    echo "${yellow}Swapfile detected. ${reset}"
    exit 1
fi

echo "${green}Swapfile created. ${reset}"
