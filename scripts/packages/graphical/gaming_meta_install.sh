#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Detect the operating system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "${red}Unable to detect the operating system ${reset}"
    exit 1
fi

# Convert operating system to lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Detect main package manager
if command -v apt > /dev/null 2>&1; then
    main_package_manager="apt"
     
elif command -v dnf > /dev/null 2>&1; then
    main_package_manager="dnf"
    
elif command -v pacman > /dev/null 2>&1; then
    main_package_manager="pacman"
    
elif command -v xbps-install > /dev/null 2>&1; then
    main_package_manager="xbps"
    
elif command -v zypper > /dev/null 2>&1; then
    main_package_manager="zypper"

elif command -v rpm-ostree > /dev/null 2>&1; then
    main_package_manager="rpm-ostree"

else
    main_package_manager="unknown"
fi

# Detect secondary package manager
if command -v flatpak > /dev/null 2>&1; then
    secondary_package_manager="flatpak"

else
    secondary_package_manager="unknown"
fi

# Distro-specific packages
debian_gaming_packages=(
"mangohud"
"steam-installer"
)

fedora_gaming_packages=(
"mangohud"
"steam"
)

openmandriva_gaming_packages=(
"mangohud"
"steam"
)

arch_gaming_packages=(
"lib32-mangohud"
"mangohud"
"steam"
)

void_gaming_packages=(
"MangoHud"
"MangoHud-32bit"
"steam"
)

opensuse_gaming_packages=(
"mangohud"
"mangohud-32bit"
"selinux-policy-targeted-gaming"
"steam"
)

# Flatpaks
auto_gaming_flatpaks=(
"com.geeks3d.furmark"
"com.github.Matoking.protontricks"
"com.heroicgameslauncher.hgl"
"io.github.ilya_zlobintsev.LACT"
"org.prismlauncher.PrismLauncher"
)

manual_gaming_flatpaks=(
"org.freedesktop.Platform.VulkanLayer.MangoHud"
)

atomic_gaming_flatpaks=(
"com.valvesoftware.Steam"
)

# Checks for main package manager and installs package(s)
if [ "$main_package_manager" = "apt" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo apt-get install -y "${debian_gaming_packages[@]}"

elif [ "$main_package_manager" = "dnf" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    # Checks for OpenMandriva
    if [ "$os" = "openmandriva" ]; then
        echo "${green}Detected Distro (ID): $os ${reset}"
        sudo dnf install -y "${openmandriva_gaming_packages[@]}"
    else
        sudo dnf install -y "${fedora_gaming_packages[@]}"
    fi

elif [ "$main_package_manager" = "pacman" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo pacman -S --needed --noconfirm "${arch_gaming_packages[@]}"
    
elif [ "$main_package_manager" = "xbps" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo xbps-install -Sy "${void_gaming_packages[@]}"

elif [ "$main_package_manager" = "zypper" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo zypper in -y "${opensuse_gaming_packages[@]}"
    
elif [ "$main_package_manager" = "rpm-ostree" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    flatpak install flathub -y "${atomic_gaming_flatpaks[@]}"
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Checks for flatpak
if [ "$secondary_package_manager" = "flatpak" ]; then
    echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
    
    # Installs package(s)
    flatpak install flathub -y "${auto_gaming_flatpaks[@]}"
    flatpak install flathub "${manual_gaming_flatpaks[@]}"
    
    # Grants flatpaks read-only access to MangoHud's config file
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark 
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
    flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher
    
fi

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for AMD GPU
if echo "$gpu_info" | grep -iq "amd"; then
    echo "${green}Detected GPU: AMD$ ${reset}"
    
    # Checks for package manager and adds kernel argument(s)
    if [ "$main_package_manager" = "rpm-ostree" ]; then
        rpm-ostree kargs --append=amdgpu.ppfeaturemask=0xffffffff
        
    elif [ -f /etc/default/grub ]; then
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
    fi
    
else
    echo "${yellow}No AMD GPU detected ${reset}"
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
    echo "${green}Detected System: Laptop ${reset}"
    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud_laptop.conf" "$HOME/.config/MangoHud/"
    
    # Changes name(s)
    mv -v "$HOME/.config/MangoHud/MangoHud_laptop.conf" "$HOME/.config/MangoHud/MangoHud.conf"
else
    echo "${green}Detected System: Desktop ${reset}"
    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud.conf" "$HOME/.config/MangoHud/"
fi

# Runs script to install latest Proton GE
chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh"
"$HOME/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh"

# Prints a conclusive message
echo "${green}Gaming packages are now installed ${reset}"
