#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs AUR helper yay if it is not already installed
    if ! command -v yay > /dev/null 2>&1; then
        echo "yay is not installed. Installing yay..."
        sudo pacman -Syu --needed --noconfirm git makepkg
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    else
        echo "yay is already installed"
    fi
        
    # Installs package(s)
    yay -S vscodium
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Adds VSCodium keyring and repository
    sudo wget https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg -O /usr/share/keyrings/vscodium-archive-keyring.asc
    echo 'deb [ arch=amd64 signed-by=/usr/share/keyrings/vscodium-archive-keyring.asc ] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list

    # Installs package(s)
    sudo apt update && sudo apt upgrade -y && sudo apt install -y codium
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Adds VSCodium keyring and repository
    sudo tee -a /etc/yum.repos.d/vscodium.repo <<- 'EOF'
    [gitlab.com_paulcarroty_vscodium_repo]
    name=gitlab.com_paulcarroty_vscodium_repo
    baseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
    enabled=1
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
    metadata_expire=1h
EOF

    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y codium
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Adds VSCodium keyring and repository
    sudo tee -a /etc/zypp/repos.d/vscodium.repo <<- 'EOF'
    [gitlab.com_paulcarroty_vscodium_repo]
    name=gitlab.com_paulcarroty_vscodium_repo
    baseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
    enabled=1
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
    metadata_expire=1h
EOF

    # Installs package(s)
    sudo zypper ref && sudo zypper dup && sudo zypper in -y codium
else
    echo "Unknown package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y app/com.vscodium.codium/x86_64/stable
fi

# Prints a conclusive message to end the script
echo "VS Codium is now installed."
