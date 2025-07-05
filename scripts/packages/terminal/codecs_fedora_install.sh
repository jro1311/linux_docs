#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for package manager
if ! command -v dnf > /dev/null 2>&1; then
    echo "Unsupported package manager"
    exit 1
fi

# Enables access to both the free and the nonfree RPM Fusion repositories
sudo dnf upgrade -y && sudo dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# Switches from default openh264 library to RPM Fusion version
sudo dnf -y config-manager setopt fedora-cisco-openh264.enabled=1

# Enables users to install packages from RPM Fusion using Gnome Software/KDE Discover
sudo dnf update -y @core

# Switches to the RPM Fusion provided ffmpeg build
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing

# Installs additional codecs
sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

# Installs package(s)
sudo dnf install -y pciutils

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for AMD GPU
if echo "$gpu_info" | grep -iq "amd"; then
    echo "Detected GPU: AMD"
    # Installs AMD-specific drivers
    sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
    sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
    sudo dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
    sudo dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
else
    echo "No AMD GPU detected"
fi

# Checks for Intel GPU
if echo "$gpu_info" | grep -iq "intel"; then
    echo "Detected GPU: Intel"
    # Checks for flatpak and flathub
    if ! command -v flatpak > /dev/null 2>&1 || ! flatpak remote-list | grep -q "flathub"; then
        # Runs script to install flatpak and set up flathub
        chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
        "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    fi
    
    # Installs Intel-specific drivers
    flatpak install flathub org.freedesktop.Platform.VAAPI.Intel
    
    # Installs Intel-specific drivers (recent)
    sudo dnf install -y intel-media-driver
    
    # Installs Intel-specific drivers (older)
    sudo dnf install libva-intel-driver
else
    echo "No Intel GPU detected"
fi
    
# Checks for Nvidia GPU
if echo "$gpu_info" | grep -iq "nvidia"; then
    echo "Detected GPU: Nvidia"
    # Installs NVIDIA-specific drivers
    sudo dnf install -y libva-nvidia-driver.{i686,x86_64}
else
    echo "No Nvidia GPU detected"
fi

# Checks for optical drive
if [ -e /dev/sr0 ]; then
    echo "Optical drive detected"
    # Enables playback of DVDs
    sudo dnf install -y rpmfusion-free-release-tainted
    sudo dnf install -y libdvdcss
else
    echo "No optical drive detected"
fi

# Enables various firmwares
sudo dnf install -y rpmfusion-nonfree-release-tainted
sudo dnf --repo=rpmfusion-nonfree-tainted install -y "*-firmware"

# Prints a conclusive message
echo "Multimedia codecs are now installed"

