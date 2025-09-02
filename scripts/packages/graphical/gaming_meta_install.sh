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

# Define bootloader
if command -v update-grub > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="update-grub"
    echo "${green}Detected Bootloader: $bootloader ${reset}"
    
elif command -v grub2-mkconfig > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub2-mkconfig -o /boot/grub2/grub.cfg"
    echo "${green}Detected Bootloader: $bootloader ${reset}"
    
elif command -v grub-mkconfig > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub-mkconfig -o /boot/grub/grub.cfg"
    echo "${green}Detected Bootloader: $bootloader ${reset}"
    
elif command -v limine-update > /dev/null 2>&1; then
    bootloader="limine"
    update_bootloader="limine-update"
    echo "${green}Detected Bootloader: $bootloader ${reset}"
    
elif find /boot/efi/EFI -name "*systemd-boot*.efi" > /dev/null 2>&1; then
    bootloader="systemd-boot"
    update_bootloader="bootctl update"
    echo "${green}Detected Bootloader: $bootloader ${reset}"
    
else
    bootloader="unknown"
    update_bootloader="unknown"
fi

# Define main package manager
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

# Define secondary package manager
if command -v flatpak > /dev/null 2>&1; then
    secondary_package_manager="flatpak"
    echo "${green}Detected Package Manger: $secondary_package_manager ${reset}"
    
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
"com.vysp3r.ProtonPlus"
"io.github.ilya_zlobintsev.LACT"
"org.prismlauncher.PrismLauncher"
)

manual_gaming_flatpaks=(
"org.freedesktop.Platform.VulkanLayer.MangoHud"
)

atomic_gaming_flatpaks=(
"com.valvesoftware.Steam"
)

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then
    sudo apt-get install -y "${debian_gaming_packages[@]}"

elif [ "$primary_package_manager" = "dnf" ]; then

    # Checks for OpenMandriva
    if [ "$os" = "openmandriva" ]; then
        echo "${green}Detected Distro (ID): $os ${reset}"
        sudo dnf install -y "${openmandriva_gaming_packages[@]}"
    else
        sudo dnf install -y "${fedora_gaming_packages[@]}"
    fi

elif [ "$primary_package_manager" = "pacman" ]; then
    sudo pacman -S --needed --noconfirm "${arch_gaming_packages[@]}"
    
elif [ "$primary_package_manager" = "xbps" ]; then
    sudo xbps-install -Sy "${void_gaming_packages[@]}"

elif [ "$primary_package_manager" = "zypper" ]; then
    sudo zypper in -y "${opensuse_gaming_packages[@]}"
    
elif [ "$primary_package_manager" = "rpm-ostree" ]; then
    flatpak install flathub -y "${atomic_gaming_flatpaks[@]}"
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Checks for package manager and installs package(s)
if [ "$secondary_package_manager" = "flatpak" ]; then
    flatpak install flathub -y "${auto_gaming_flatpaks[@]}"
    flatpak install flathub "${manual_gaming_flatpaks[@]}"
    
    # Grants flatpaks read-only access to MangoHud's config file
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
    flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher

    # Forces LACT flatpak to use Adwaita dark theme
    flatpak override --user --env GTK_THEME=Adwaita:dark io.github.ilya_zlobintsev.LACT
fi

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for AMD GPU
if echo "$gpu_info" | grep -Fiq "amd"; then
    echo "${green}Detected GPU: AMD ${reset}"
    
    # Checks for package manager or bootloader, then adds kernel argument(s)
    if [ "$primary_package_manager" = "rpm-ostree" ]; then
        if ! rpm-ostree kargs | grep -Fq "amdgpu.ppfeaturemask=0xffffffff"; then
        
            sudo rpm-ostree kargs --append=amdgpu.ppfeaturemask=0xffffffff
            echo "${green}Added amdgpu.ppfeaturemask=0xffffffff to kernel arguments  ${reset}"
            
        else
            echo "${green}amdgpu.ppfeaturemask=0xffffffff already part of kernel arguments ${reset}"
        fi
        
    elif [ "$bootloader" = "grub" ]; then
        if ! grep -Fq "amdgpu.ppfeaturemask=0xffffffff" /etc/default/grub; then
            
            sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 amdgpu.ppfeaturemask=0xffffffff"/' /etc/default/grub
            echo "${green}Added amdgpu.ppfeaturemask=0xffffffff to kernel arguments  ${reset}"
            
        else
            echo "${green}amdgpu.ppfeaturemask=0xffffffff already part of kernel arguments ${reset}"
        fi
        
        sudo bash -c "$update_bootloader"
        
    elif [ "$bootloader" = "limine" ]; then
        if ! grep -Fq "amdgpu.ppfeaturemask=0xffffffff" /etc/default/limine; then
        
            sudo sed -i '/^KERNEL_CMDLINE\[default\]/ s/"$/ amdgpu.ppfeaturemask=0xffffffff"/' /etc/default/limine
            echo "${green}Added amdgpu.ppfeaturemask=0xffffffff to kernel arguments  ${reset}"
            
        else
            echo "${green}amdgpu.ppfeaturemask=0xffffffff already part of kernel arguments ${reset}"
        fi
        
        sudo bash -c "$update_bootloader"
        
    else
        echo "${red}Unable to add kernel argument(s) ${reset}"
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
    cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud.conf" "$HOME/.config/MangoHud/"
    
    # Edits FPS limits
    sed -i 's/fps_limit=160,120,90,60,30,0/fps_limit=60,30,0/' "$HOME/.config/MangoHud/MangoHud.conf"
    
else
    echo "${green}Detected System: Desktop ${reset}"
    
    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud.conf" "$HOME/.config/MangoHud/"
fi

# Adds output folder for MangoHud logs
echo "output_folder=$HOME/Documents/mangohud/logs" >> "$HOME/.config/MangoHud/MangoHud.conf"

# Prints a conclusive message
echo "${green}Gaming packages are now installed ${reset}"
