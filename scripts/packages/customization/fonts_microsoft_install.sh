#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Define the operating system and convert it to lowercase
if [ -f /etc/os-release ]; then
    . /etc/os-release

    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"

    os="${os,,}"
    os_like="${os_like,,}"

    echo "${green}Distro (ID): $os ${reset}"
    echo "${green}Distro (ID_LIKE): $os_like ${reset}"

else
    echo "${red}Unable to detect the operating system. ${reset}"
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

# Checks for package manager and installs package(s)
case "$primary_package_manager" in
    "apt")
        sudo apt-get install -y software-properties-common

        case "$os" in
            "debian")
                sudo apt-add-repository -y contrib non-free-firmware
                ;;
            "ubuntu")
                sudo add-apt-repository multiverse
                ;;
            *)
                case "$os_like" in
                    "debian")
                        sudo apt-add-repository -y contrib non-free-firmware
                        ;;
                    "ubuntu debian"|"ubuntu")
                        sudo add-apt-repository multiverse
                        ;;
                    *)
                        echo "${red}Unsupported distribution. ${reset}"
                        exit 1
                        ;;
                esac
                ;;
        esac

        sudo apt-get install -y fontconfig ttf-mscorefonts-installer
        ;;
    "dnf")
        if [ "$os" = "openmandriva" ]; then
            echo "${yellow}Manual installation required. ${reset}"
            exit 0
        else
            sudo dnf install -y cabextract curl fontconfig xorg-x11-font-utils
            sudo dnf install -y https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
        fi
        ;;
    "eopkg")
        sudo eopkg install -y fonts-installer fontconfig
        ;;
    "pacman")
        if [[ "$secondary_package_manager" =~ ^(paru|yay)$ ]]; then
            "$secondary_package_manager" -S ttf-ms-win11-auto
        else
            sudo pacman -S --needed --noconfirm base-devel git makepkg
            git clone https://aur.archlinux.org/paru.git
            cd paru
            makepkg -si --noconfirm
            cd ..
            rm -rf paru
            paru -S ttf-ms-win11-auto
        fi
        ;;
    xbps)
        sudo xbps-install -Sy greybird-themes
        ;;
    "zypper")
        sudo zypper in -y fetchmsttfonts fontconfig
        ;;
    "rpm-ostree")
        echo "${yellow}Run 'fonts_microsoft_fedora_atomic_install.sh' instead. ${reset}"
        exit 0
        ;;
    *)
        echo "${yellow}Manual installation required. ${reset}"
        exit 0
        ;;
esac

# Makes directory(s)
mkdir -pv "$HOME/.config/fontconfig"

# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/fontconfig/fonts.conf" "$HOME/.config/fontconfig/"

# Prints a conclusive message
echo "${green}Microsoft fonts are now installed. ${reset}"
