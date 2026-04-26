#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define the operating system and convert it to lowercase
if [ -f /etc/os-release ]; then
    . /etc/os-release

    os="${ID:-}"
    os_like="${ID_LIKE:-$os}"

    os=$(printf '%s' "$os" | tr 'A-Z' 'a-z')
    os_like=$(printf '%s' "$os_like" | tr 'A-Z' 'a-z')

    # Normalize whitespace
    os_like=$(printf '%s' "$os_like" | tr -s ' ')
else
    echo "${red}Unable to detect the operating system.${reset}"
    exit 1
fi

if [ "$os_like" != "$os" ]; then
    echo "${green}Base Distro(s):${reset} $os_like"
fi

echo "${green}Distro:${reset} $os"

if [ -n "$VERSION_ID" ]; then
    echo "${green}Version:${reset} $VERSION_ID"
fi

# List of packages
pkgs=(
    pkg1
    pkg2
)

aur_pkgs=(
    aur-pkg1
    aur-pkg2
)

flatpaks=(
    flatpak1
    flatpak2
)

# Executes commands based on the operating system
case "$os" in
    arch)
        sudo pacman -S --needed --noconfirm "${pkgs[@]}"
        ;;
    debian|ubuntu)
        sudo apt-get install -y "${pkgs[@]}"
        ;;
    fedora|openmandriva)
        sudo dnf install -y "${pkgs[@]}"
        ;;
    opensuse*)
        sudo zypper in -y "${pkgs[@]}"
        ;;
    solus)
        sudo eopkg install -y "${pkgs[@]}"
        ;;
    void)
        sudo xbps-install -Sy "${pkgs[@]}"
        ;;
    *)
        case " $os_like " in
            *" arch "*)
                sudo pacman -S --needed --noconfirm "${pkgs[@]}"
                ;;
            *" debian "*|*" ubuntu "*)
                sudo apt-get install -y "${pkgs[@]}"
                ;;
            *" fedora "*)
                sudo dnf install -y "${pkgs[@]}"
                ;;
            *" opensuse "*|*" suse "*)
                sudo zypper in -y "${pkgs[@]}"
                ;;
            *" solus "*)
                sudo eopkg install -y "${pkgs[@]}"
                ;;
            *" void "*)
                sudo xbps-install -Sy "${pkgs[@]}"
                ;;
            *)
                echo "${red}Unsupported distribution.${reset}"
                exit 1
                ;;
        esac
        ;;
esac
