#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

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

# Check for Flatpak
flatpak_installed=0
if command -v flatpak > /dev/null 2>&1; then
    flatpak_installed=1
    echo "${green}Flatpak detected. ${reset}"
fi

# Check for Snap
snap_installed=0
if command -v snap > /dev/null 2>&1; then
    snap_installed=1
    echo "${green}Snap detected. ${reset}"
fi

# List of packages
packages=("codium")
aur_packages=("vscodium")
flatpaks=("com.vscodium.codium")
snaps=("codium")

# Checks for package manager and installs package(s)
case "$primary_package_manager" in
    "apt")
        # Adds VSCodium keyring and repository
        sudo wget https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg -O /usr/share/keyrings/vscodium-archive-keyring.asc
        echo 'deb [ arch=amd64 signed-by=/usr/share/keyrings/vscodium-archive-keyring.asc ] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
        sudo apt-get install -y "${packages[@]}"
        ;;
    "dnf")
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
        sudo dnf install -y "${packages[@]}"
        ;;
    "pacman")
        if [[ "$secondary_package_manager" =~ ^(paru|yay)$ ]]; then
            "$secondary_package_manager" -S --needed --noconfirm "${aur_packages[@]}"
        else
            sudo pacman -S --needed --noconfirm base-devel git
            git clone https://aur.archlinux.org/paru.git
            cd paru
            makepkg -si --noconfirm
            cd ..
            rm -rf paru
            paru -S --needed --noconfirm "${aur_packages[@]}"
        fi
        ;;
    "xbps")
        sudo xbps-install -Sy vscode
        ;;
    "zypper")
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
        sudo zypper in -y "${packages[@]}"
        ;;
    *)
        if [[ "$flatpak_installed" -eq 1 ]]; then
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            flatpak install flathub -y "${flatpaks[@]}"

        elif [[ "$snap_installed" -eq 1 ]]; then
            sudo snap install "${snaps[@]}" --classic

        else
            echo "${red}Unsupported package manager. ${reset}"
            exit 1
        fi
        ;;
esac

# Prints a conclusive message
echo "${green}Visual Studio Codium is now installed. ${reset}"

