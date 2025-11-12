#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Enables nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Detect host system
host_system="unknown"
batteries=(/sys/class/power_supply/BAT*)

if (( ${#batteries[@]} )); then
    host_system="laptop"
else
    host_system="desktop"
fi

if [ "$host_system" != "unknown" ]; then
    echo "${green}Host System: $host_system ${reset}"
fi

# Disables nullglob
shopt -u nullglob

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

# Check for Flatpak
flatpak_installed=0
if command -v flatpak > /dev/null 2>&1; then
    flatpak_installed=1
    echo "${green}Flatpak detected. ${reset}"
fi

# Define bootloader
bootloader="unknown"
update_bootloader="unknown"

if command -v update-grub > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="update-grub"

elif command -v grub2-mkconfig > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub2-mkconfig -o /boot/grub2/grub.cfg"

elif command -v grub-mkconfig > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub-mkconfig -o /boot/grub/grub.cfg"

elif command -v limine-update > /dev/null 2>&1; then
    bootloader="limine"
    update_bootloader="limine-update"

elif find /boot/efi/EFI -name "*systemd-boot*.efi" > /dev/null 2>&1; then
    bootloader="systemd-boot"
    update_bootloader="bootctl update"
fi

if [ "$bootloader" != "unknown" ]; then
    echo "${green}Bootloader: $bootloader ${reset}"
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

opensuse_gaming_packages=(
"mangohud"
"mangohud-32bit"
"selinux-policy-targeted-gaming"
"steam"
)

solus_gaming_packages=(
"mangohud"
"steam"
)

void_gaming_packages=(
"MangoHud"
"MangoHud-32bit"
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
case "$primary_package_manager" in
    "apt")
        # Enables 32-bit libraries
        sudo dpkg --add-architecture i386 && sudo apt-get update
        sudo apt-get install -y "${debian_gaming_packages[@]}"
        ;;
    "dnf")
        if [ "$os" = "openmandriva" ]; then
            sudo dnf install -y "${openmandriva_gaming_packages[@]}"
        else
            sudo dnf install -y "${fedora_gaming_packages[@]}"
        fi
        ;;
    "eopkg")
        sudo eopkg install -y "${solus_gaming_packages[@]}"
        ;;
    "pacman")
        sudo pacman -S --needed --noconfirm "${arch_gaming_packages[@]}"
        ;;
    "xbps")
        sudo xbps-install -Sy "${void_gaming_packages[@]}"
        ;;
    "zypper")
        sudo zypper in -y "${opensuse_gaming_packages[@]}"
        ;;
    "rpm-ostree")
        ;;
    *)
        echo "${red}Unsupported package manager. ${reset}"
        exit 1
        ;;
esac

# Checks for Flatpak and installs package(s)
if [ "$flatpak_installed" -eq 1 ]; then
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    if [ "$primary_package_manager" = "rpm-ostree" ]; then
        flatpak install flathub -y "${atomic_gaming_flatpaks[@]}"
    fi

    flatpak install flathub -y "${auto_gaming_flatpaks[@]}"
    flatpak install flathub "${manual_gaming_flatpaks[@]}"
    
    # Grants flatpaks read-only access to MangoHud's config file
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
    flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher
fi

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Kernel argument(s)
gpu_karg="amdgpu.ppfeaturemask=0xffffffff"

# Checks for AMD GPU
if echo "$gpu_info" | grep -Fiq "amd"; then
    echo "${green}Detected GPU: AMD ${reset}"

    # Checks for package manager or bootloader, then adds kernel argument(s)
    case "$primary_package_manager" in
        "rpm-ostree")
            if ! rpm-ostree kargs | grep -Fq "$gpu_karg"; then
                sudo rpm-ostree kargs --append="$gpu_karg"
                echo "${green}'$gpu_karg' added to kernel arguments. ${reset}"

            else
                echo "${green}'$gpu_karg' is already part of kernel arguments. ${reset}"
            fi
            ;;
        *)
            case "$bootloader" in
                "grub")
                    if ! grep -Fq "$gpu_karg" /etc/default/grub; then
                        sudo sed -i "s/\(GRUB_CMDLINE_LINUX=\"[^\"]*\)\"/\1 $gpu_karg\"/" /etc/default/grub
                        sudo bash -c "$update_bootloader"
                        echo "${green}'$gpu_karg' added to kernel arguments. ${reset}"

                    else
                        echo "${green}'$gpu_karg' is already part of kernel arguments. ${reset}"
                    fi
                    ;;
                "limine")
                    if ! grep -Fq "$gpu_karg" /etc/default/limine; then
                        sudo sed -i "/^KERNEL_CMDLINE\[default\\]/ s/\"$/ $gpu_karg\"/" /etc/default/limine
                        sudo bash -c "$update_bootloader"
                        echo "${green}'$gpu_karg' added to kernel arguments. ${reset}"

                    else
                        echo "${green}'$gpu_karg' is already part of kernel arguments. ${reset}"
                    fi
                    ;;
            esac
            ;;
    esac

else
    echo "${yellow}No AMD GPU detected. ${reset}"
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/MangoHud"
mkdir -pv "$HOME/Documents/mangohud/logs"

# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud.conf" "$HOME/.config/MangoHud/"

# Checks host system
if [ "$host_system" = "laptop" ]; then

    # Edits FPS limits
    sed -i 's/fps_limit=160,120,90,60,30,0/fps_limit=60,30,0/' "$HOME/.config/MangoHud/MangoHud.conf"
    
fi

# Adds output folder for MangoHud logs
echo "output_folder=$HOME/Documents/mangohud/logs" >> "$HOME/.config/MangoHud/MangoHud.conf"

# Prints a conclusive message
echo "${green}Gaming packages are now installed. ${reset}"
