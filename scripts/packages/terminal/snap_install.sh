#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Checks for init system
if ps -p 1 -o comm= | grep -Fq "systemd"; then
    echo "${green}Detected Init System: systemd ${reset}"
else
    echo "${red}Unsupported init system. ${reset}"
    exit 1
fi

# Define the operating system and convert it to lowercase
if [ -f /etc/os-release ]; then
    . /etc/os-release

    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"

    os="${os,,}"
    os_like="${os_like,,}"

    echo "${green}Distro (ID): $os ${reset}"
    echo "${green}Distro (ID_LIKE): $os_like ${reset}"

    debian_version="0"
    ubuntu_version="0"
    fedora_version="0"
    openmandriva_version="0"
    opensuse_version="0"

    case "$os" in
        "debian")
            debian_version="${VERSION_ID-:0}"
            echo "${green}Version: $debian_version ${reset}"
            ;;
        "ubuntu")
            ubuntu_version="${VERSION_ID-:0}"
            echo "${green}Version: $ubuntu_version ${reset}"
            ;;
        "fedora")
            fedora_version="${VERSION_ID-:0}"
            echo "${green}Version: $fedora_version ${reset}"
            ;;
        "openmandriva")
            openmandriva_version="${VERSION_ID-:0}"
            echo "${green}Version: $openmandriva_version ${reset}"
            ;;
        "opensuse-leap")
            opensuse_version="${VERSION_ID-:0}"
            echo "${green}Version: $opensuse_version ${reset}"
            ;;
        *)
            case "$os_like" in
                "debian")
                    debian_version="${VERSION_ID-:0}"
                    echo "${green}Version: $debian_version ${reset}"
                    ;;
                "ubuntu debian")
                    ubuntu_version="${VERSION_ID-:0}"
                    echo "${green}Version: $ubuntu_version ${reset}"
                    ;;
                "fedora")
                    fedora_version="${VERSION_ID-:0}"
                    echo "${green}Version: $fedora_version ${reset}"
                    ;;
            esac
            ;;
    esac
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

# List of packages
packages=("snapd")

# Checks for package manager and installs package(s)
case "$primary_package_manager" in
    "apt")
        # Unlocks package(s) if they are locked
        if apt-mark showhold | grep -q "^snapd$"; then
            sudo apt-mark unhold snapd
        fi

        sudo apt-get install -y "${packages[@]}"
        sudo snap install snapd
        ;;
    "dnf")
        sudo dnf install -y "${packages[@]}"
        ;;
    "eopkg")
        sudo eopkg install -y "${packages[@]}"
        ;;
    "pacman")
        if [[ "$secondary_package_manager" =~ ^(paru|yay)$ ]]; then
            "$secondary_package_manager" -S --needed --noconfirm "${packages[@]}"
        else
            sudo pacman -S --needed --noconfirm base-devel git
            git clone https://aur.archlinux.org/paru.git
            cd paru
            makepkg -si --noconfirm
            cd ..
            rm -rf paru
            paru -S --needed --noconfirm "${packages[@]}"
        fi
        ;;
    "zypper")
        case "$os" in
            "opensuse-tumbleweed"|"opensuse-slowroll")
                sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
                sudo zypper --gpg-auto-import-keys refresh
                sudo zypper in -y "${packages[@]}"
                ;;
            "opensuse-leap")
                sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Leap_16.0 snappy
                sudo zypper --gpg-auto-import-keys refresh
                sudo zypper in -y "${packages[@]}"
                ;;
            *)
                echo "${red}Unsupported operating system ${reset}"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "${red}Unsupported package manager. ${reset}"
        exit 1
        ;;
esac

# Enables snap daemon
sudo systemctl enable --now snapd

# Enables classic snap support
sudo ln -s /var/lib/snapd/snap /snap

# Installs package(s)
sudo snap install snap-store

# Prints a conclusive message
echo "${green}Snap is now installed. ${reset}"
