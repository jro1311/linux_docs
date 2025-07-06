#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Detect the operating system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "Unable to detect the operating system"
    exit 1
fi

# Convert operating system to lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Prints the detected operating system
echo "Detected (ID): $os"
echo "Detected (ID_LIKE): $os_like"

# Distro-specific packages
debian_gaming_packages=("mangohud" "steam-installer")
fedora_gaming_packages=("mangohud" "steam")
openmandriva_gaming_packages=("mangohud" "steam")
arch_gaming_packages=("lib32-mangohud" "mangohud" "steam")
void_gaming_packages=("MangoHud" "MangoHud-32bit" "steam")
opensuse_gaming_packages=("mangohud" "mangohud-32bit" "selinux-policy-targeted-gaming" "steam")

# Flatpaks
auto_gaming_flatpaks=("furmark" "heroicgameslauncher" "lact" "prismlauncher" "com.github.Matoking.protontricks/x86_64/stable")
manual_gaming_flatpaks=("org.freegaming.Platform.VulkanLayer.MangoHud")
atomic_gaming_flatpaks=("com.valvesoftware.Steam")

# Checks for package manager and installs package(s)
if command -v apt > /dev/null 2>&1; then
    sudo nala install -y "${debian_gaming_packages[@]}"
        
elif command -v dnf > /dev/null 2>&1; then
    if [ "$os" = "openmandriva" ]; then
        sudo dnf install -y "${openmandriva_gaming_packages[@]}"
    else
        sudo dnf install -y "${fedora_gaming_packages[@]}"
    fi
        
elif command -v pacman > /dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm "${arch_gaming_packages[@]}"
    
elif command -v xbps-install > /dev/null 2>&1; then
    sudo xbps-install -Sy "${void_gaming_packages[@]}"
        
elif command -v zypper > /dev/null 2>&1; then
    sudo zypper in -y "${opensuse_gaming_packages[@]}"
fi
    
# Installs package(s)
flatpak install flathub -y "${auto_gaming_flatpaks[@]}"
flatpak install flathub "${manual_gaming_flatpaks[@]}"
    
# Checks for package manager
if command -v rpm-ostree > /dev/null 2>&1; then
    flatpak install flathub -y "${atomic_gaming_flatpaks[@]}"
fi

# Grants flatpaks read-only access to MangoHud's config file
flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark 
flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for AMD GPU
if echo "$gpu_info" | grep -iq "amd"; then
    echo "Detected GPU: AMD"
    # Checks for package manager and adds kernel argument(s)
    if command -v rpm-ostree > /dev/null 2>&1; then
        rpm-ostree kargs --append=amdgpu.ppfeaturemask=0xffffffff
        
    elif [ -f /etc/default/grub ]; then
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
    fi
else
    echo "No AMD GPU detected"
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/MangoHud"
mkdir -pv "$HOME/Documents/mangohud/logs"

# Enables nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Detect batteries
batteries=(/sys/class/power_supply/BAT*)

# Checks for battery
if (( ${#batteries[@]} )); then
    echo "Detected System: Laptop"
    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud_laptop.conf" "$HOME/.config/MangoHud/"
    
    # Changes name(s)
    mv -v "$HOME/.config/MangoHud/MangoHud_laptop.conf" "$HOME/.config/MangoHud/MangoHud.conf"
else
    echo "Detected System: Desktop"
    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud.conf" "$HOME/.config/MangoHud/"
fi

# Runs script to install latest Proton GE
chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh"
"$HOME/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh"

# Prints a conclusive message
echo "Gaming packages are now installed"
