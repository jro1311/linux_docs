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

    os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
    os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

    echo "${green}Detected Distro (ID): $os ${reset}"
    echo "${green}Detected Distro (ID_LIKE): $os_like ${reset}"

else
    echo "${red}Unable to detect the operating system ${reset}"
    exit 1
fi

# Define primary package manager
if command -v apt > /dev/null 2>&1; then
    primary_package_manager="apt"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

elif command -v dnf > /dev/null 2>&1; then
    primary_package_manager="dnf"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

elif command -v pacman > /dev/null 2>&1; then
    primary_package_manager="pacman"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

elif command -v xbps-install > /dev/null 2>&1; then
    primary_package_manager="xbps"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

elif command -v zypper > /dev/null 2>&1; then
    primary_package_manager="zypper"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

elif command -v rpm-ostree > /dev/null 2>&1; then
    primary_package_manager="rpm-ostree"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"

else
    primary_package_manager="unknown"
fi

# Define the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')
echo "${green}Detected Desktop: $desktop ${reset}"

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then

    # Executes commands based on the operating system
    case "$os" in
        "debian")
            # Converts old sources.list format into modern debian.sources format
            sudo apt modernize-sources -y

            # Checks for contrib repository
            if ! grep -Fq "contrib" /etc/apt/sources.list.d/debian.sources; then

                # Adds repo(s)
                sudo sed -i '/Components:/ s/$/ contrib/' /etc/apt/sources.list.d/debian.sources
                sudo apt-get update
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
                    # Converts old sources.list format into modern debian.sources format
                    sudo apt modernize-sources -y

                    # Checks for contrib repository
                    if ! grep -Fq "contrib" /etc/apt/sources.list.d/debian.sources; then

                        # Adds repo(s)
                        sudo sed -i '/Components:/ s/$/ contrib/' /etc/apt/sources.list.d/debian.sources
                        sudo apt-get update
                    fi
                    ;;
                "ubuntu"|"ubuntu debian")
                    sudo apt-get install -y software-properties-common
                    sudo add-apt-repository multiverse
                    sudo apt-get install -y ubuntu-restricted-addons ubuntu-restricted-extras
                    ;;
                *)
                    echo "${red}Unsupported distribution ${reset}"
                    exit 1
                    ;;
            esac
            ;;
    esac

    # Checks for Ubuntu
    if [ "$os" = "ubuntu" ]; then
        case "$desktop" in
            "kde"|"plasma")
                sudo apt-get install -y kubuntu-restricted-addons kubuntu-restricted-extras
                ;;
            "lxqt")
                sudo apt-get install -y lubuntu-restricted-addons lubuntu-restricted-extras
                ;;
            "xfce")
                sudo apt-get install -y xubuntu-restricted-addons xubuntu-restricted-extras
                ;;
        esac
    fi

    sudo apt-get install -y libavcodec-extra

    # Checks for optical drive
    if [ -e /dev/sr0 ]; then
        echo "${green}Optical drive detected ${reset}"
        sudo apt-get install -y libdvd-pkg
    else
        echo "${yellow}No optical drive detected ${reset}"
    fi

elif [ "$primary_package_manager" = "dnf" ]; then

    if [ "$os" = "openmandriva" ]; then

        sudo dnf install -y faac flac lib64dca0 lib64xvid4 x264 x265

        # Checks for optical drive
        if [ -e /dev/sr0 ]; then
            echo "${green}Optical drive detected ${reset}"
            sudo dnf install -y lib64dvdcss lib64dvdnav4 lib64dvdread
        else
            echo "${yellow}No optical drive detected ${reset}"
        fi

    else
        # Enables access to both the free and the nonfree RPM Fusion repositories
        sudo dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

        # Switches from default openh264 library to RPM Fusion version
        sudo dnf -y config-manager setopt fedora-cisco-openh264.enabled=1

        # Enables users to install packages from RPM Fusion using Gnome Software/KDE Discover
        sudo dnf update -y @core

        # Switches to the RPM Fusion provided ffmpeg build
        sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing

        # Installs additional codecs
        sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

        sudo dnf install -y pciutils

        # Get GPU information
        gpu_info=$(lspci | grep -E "VGA|3D")

        # Checks for AMD GPU
        if echo "$gpu_info" | grep -iq "amd"; then
            echo "${green}Detected GPU: AMD ${reset}"

            # Installs AMD-specific drivers
            sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
            sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
            sudo dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
            sudo dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686

        else
            echo "${yellow}No AMD GPU detected ${reset}"
        fi

        # Checks for Intel GPU
        if echo "$gpu_info" | grep -iq "intel"; then
            echo "${green}Detected GPU: Intel ${reset}"

            # Installs Intel-specific drivers (newer)
            sudo dnf install -y intel-media-driver

            # Installs Intel-specific drivers (older)
            sudo dnf install libva-intel-driver

        else
            echo "${yellow}No Intel GPU detected ${reset}"
        fi

        # Checks for Nvidia GPU
        if echo "$gpu_info" | grep -iq "nvidia"; then
            echo "${green}Detected GPU: Nvidia ${reset}"

            # Installs NVIDIA-specific drivers
            sudo dnf install -y libva-nvidia-driver.{i686,x86_64}

        else
            echo "${yellow}No Nvidia GPU detected ${reset}"
        fi

        # Checks for optical drive
        if [ -e /dev/sr0 ]; then
            echo "${green}Optical drive detected ${reset}"

            # Enables playback of DVDs
            sudo dnf install -y rpmfusion-free-release-tainted
            sudo dnf install -y libdvdcss
        else
            echo "${yellow}No optical drive detected ${reset}"
        fi

        # Enables various firmwares
        sudo dnf install -y rpmfusion-nonfree-release-tainted
        sudo dnf --repo=rpmfusion-nonfree-tainted install -y "*-firmware"
    fi

elif [ "$primary_package_manager" = "pacman" ]; then

    sudo pacman -S --needed --noconfirm mpv

elif [ "$primary_package_manager" = "xbps" ]; then

    sudo xbps-install -Sy faac flac x264 x265

    # Checks for optical drive
    if [ -e /dev/sr0 ]; then
        echo "${green}Optical drive detected ${reset}"
        sudo xbps-install -y lib64dvdcss lib64dvdnav4 lib64dvdread
    else
        echo "${yellow}No optical drive detected ${reset}"
    fi

elif [ "$primary_package_manager" = "zypper" ]; then

    sudo zypper in -y opi && opi codecs

fi

# Prints a conclusive message
echo "${green}Multimedia codecs are now installed. ${reset}"
