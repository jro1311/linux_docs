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

    debian_version="0"
    ubuntu_version="0"
    fedora_version="0"
    openmandriva_version="0"
    opensuse_version="0"
    solus_version="0"

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
        "solus")
            solus_version="${VERSION_ID-:0}"
            echo "${green}Version: $solus_version ${reset}"
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

# Define the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')
echo "${green}Desktop: $desktop ${reset}"

# Checks for package manager and installs package(s)
install_codecs_apt() {
    case "$os" in
        "debian")
            sudo apt modernize-sources -y
            if ! grep -Fq "contrib" /etc/apt/sources.list.d/debian.sources; then
                sudo sed -i '/Components:/ s/$/ contrib/' /etc/apt/sources.list.d/debian.sources
                sudo apt-get update
                echo "${green}Enabled: Debian contrib repository. ${reset}"
            fi
            ;;
        "linuxmint")
            sudo apt-get install -y software-properties-common
            sudo add-apt-repository multiverse
            sudo apt-get install -y mint-meta-codecs
            ;;
        "ubuntu")
            sudo apt-get install -y software-properties-common
            sudo add-apt-repository multiverse
            sudo apt-get install -y ubuntu-restricted-addons ubuntu-restricted-extras
            ;;
        *)
            case "$os_like" in
                "debian")
                    sudo apt modernize-sources -y
                    if ! grep -Fq "contrib" /etc/apt/sources.list.d/debian.sources; then
                        sudo sed -i '/Components:/ s/$/ contrib/' /etc/apt/sources.list.d/debian.sources
                        sudo apt-get update
                        echo "${green}Enabled: Debian contrib repository. ${reset}"
                    fi
                    ;;
                "ubuntu"|"ubuntu debian")
                    sudo apt-get install -y software-properties-common
                    sudo add-apt-repository multiverse
                    sudo apt-get install -y ubuntu-restricted-addons ubuntu-restricted-extras
                    ;;
                *)
                    echo "${red}Unsupported distribution. ${reset}"
                    exit 1
                    ;;
            esac
            ;;
    esac

    if [ "$os" = "ubuntu" ]; then
        case "$desktop" in
            "kde"|"plasma") sudo apt-get install -y kubuntu-restricted-addons kubuntu-restricted-extras ;;
            "lxqt") sudo apt-get install -y lubuntu-restricted-addons lubuntu-restricted-extras ;;
            "xfce") sudo apt-get install -y xubuntu-restricted-addons xubuntu-restricted-extras ;;
        esac
    fi

    sudo apt-get install -y libavcodec-extra

    if [ -e /dev/sr0 ]; then
        echo "${green}Optical drive detected. ${reset}"
        sudo apt-get install -y libdvd-pkg
    else
        echo "${yellow}No optical drive detected. ${reset}"
    fi
}

install_codecs_dnf() {
    if [ "$os" = "openmandriva" ]; then
        sudo dnf install -y faac flac lib64dca0 lib64xvid4 x264 x265

        if [ -e /dev/sr0 ]; then
            echo "${green}Optical drive detected. ${reset}"
            sudo dnf install -y lib64dvdcss lib64dvdnav4 lib64dvdread
        else
            echo "${yellow}No optical drive detected. ${reset}"
        fi

    else

        sudo dnf install -y \
            "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
            "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

        sudo dnf -y config-manager setopt fedora-cisco-openh264.enabled=1
        sudo dnf update -y @core
        sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
        sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
        sudo dnf install -y opus pciutils

        gpu_info=$(lspci | grep -E "VGA|3D")

        if echo "$gpu_info" | grep -iq "amd"; then
            echo "${green}Detected GPU: AMD ${reset}"
            sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
            sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
            sudo dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
            sudo dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
        fi

        if echo "$gpu_info" | grep -iq "intel"; then
            echo "${green}Detected GPU: Intel ${reset}"
            sudo dnf install -y intel-media-driver
            sudo dnf install libva-intel-driver
        fi

        if echo "$gpu_info" | grep -iq "nvidia"; then
            echo "${green}Detected GPU: Nvidia ${reset}"
            sudo dnf install -y libva-nvidia-driver.{i686,x86_64}
        fi

        if [ -e /dev/sr0 ]; then
            echo "${green}Optical drive detected. ${reset}"
            sudo dnf install -y rpmfusion-free-release-tainted
            sudo dnf install -y libdvdcss
        fi

        sudo dnf install -y rpmfusion-nonfree-release-tainted
        sudo dnf --repo=rpmfusion-nonfree-tainted install -y "*-firmware"

    fi
}

install_codecs_eopkg() {
    sudo eopkg install -y aom opus x264 x265

    if [ -e /dev/sr0 ]; then
        echo "${green}Optical drive detected. ${reset}"
        sudo eopkg install -y libdvdcss libdvdnav libdvdread
    fi
}

install_codecs_pacman() {
    sudo pacman -S --needed --noconfirm opus mpv
}

install_codecs_xbps() {
    sudo xbps-install -Sy faac flac opus x264 x265

    if [ -e /dev/sr0 ]; then
        echo "${green}Optical drive detected. ${reset}"
        sudo xbps-install -y lib64dvdcss lib64dvdnav4 lib64dvdread
    fi
}

install_codecs_zypper() {
    sudo zypper in -y opi && opi codecs
}

# Checks for package manager and installs package(s)
case "$primary_package_manager" in
    "apt")
        install_codecs_apt
        ;;
    "dnf")
        install_codecs_dnf
        ;;
    "eopkg")
        install_codecs_eopkg
        ;;
    "pacman")
        install_codecs_pacman
        ;;
    "xbps")
        install_codecs_xbps
        ;;
    "zypper")
        install_codecs_zypper
        ;;
    *)
        echo "${red}Unsupported package manager. ${reset}"
        exit 1
        ;;
esac

# Prints a conclusive message
echo "${green}Multimedia codecs are now installed. ${reset}"
