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
    update_bootloader="sudo update-grub"
    echo "${green}Detected Bootloader: $bootloader ${reset}"
    
elif command -v grub2-mkconfig > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
    echo "${green}Detected Bootloader: $bootloader ${reset}"
    
elif command -v grub-mkconfig > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="sudo grub-mkconfig -o /boot/grub/grub.cfg"
    echo "${green}Detected Bootloader: $bootloader ${reset}"
    
else
    bootloader="unknown"
    update_bootloader="unknown"
fi

# Define main package manager
if command -v apt > /dev/null 2>&1; then
    primary_package_manager="apt"
    echo "Detected Package Manager: $primary_package_manager"
    
elif command -v dnf > /dev/null 2>&1; then
    primary_package_manager="dnf"
    echo "Detected Package Manager: $primary_package_manager"
    
elif command -v pacman > /dev/null 2>&1; then
    primary_package_manager="pacman"
    echo "Detected Package Manager: $primary_package_manager"
    
elif command -v xbps-install > /dev/null 2>&1; then
    primary_package_manager="xbps"
    echo "Detected Package Manager: $primary_package_manager"
    
elif command -v zypper > /dev/null 2>&1; then
    primary_package_manager="zypper"
    echo "Detected Package Manager: $primary_package_manager"
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    primary_package_manager="rpm-ostree"
    echo "Detected Package Manager: $primary_package_manager"
    
else
    primary_package_manager="unknown"
fi

# List of packages
packages=("corectrl")

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then
    sudo apt-get install -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "dnf" ]; then
    sudo dnf install -y "${packages[@]}"
    
elif [ "$primary_package_manager" = "pacman" ]; then
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
elif [ "$primary_package_manager" = "xbps" ]; then
    sudo xbps-install -Sy "${packages[@]}"
    
elif [ "$primary_package_manager" = "zypper" ]; then

    # Checks for openSUSE distro
    if [ "$os" = "opensuse-tumbleweed" ]; then
    
        # Adds repo(s)
        sudo zypper addrepo https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Tumbleweed/home:Dead_Mozay.repo
        sudo zypper in -y "${packages[@]}"
        
    elif [ "$os" = "opensuse-slowroll" ]; then
    
        # Adds repo(s)
        sudo zypper addrepo https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Slowroll/home:Dead_Mozay.repo
        sudo zypper in -y "${packages[@]}"
        
    else
        echo "${red}Unsupported operating system ${reset}"
        exit 1
    fi
    
elif [ "$primary_package_manager" = "rpm-ostree" ]; then
    sudo rpm-ostree install "${packages[@]}"
    
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Get the current user's primary group
group=$(id -gn)

# Creates a polkit rule file with the current user's primary group
sudo tee /etc/polkit-1/rules.d/90-corectrl.rules << EOF
polkit.addRule(function(action, subject) {
    if ((action.id == 'org.corectrl.helper.init' ||
        action.id == 'org.corectrl.helperkiller.init') &&
        subject.local == true &&
        subject.active == true &&
        subject.isInGroup("$group")) {
            return polkit.Result.YES;
    }
});
EOF

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for AMD GPU
if echo "$gpu_info" | grep -Fiq "amd"; then
    echo "${green}Detected GPU: AMD$ ${reset}"
    
    # Checks for package manager or bootloader, then adds kernel argument(s)
    if [ "$primary_package_manager" = "rpm-ostree" ]; then
        if ! rpm-ostree kargs | grep -Fq "amdgpu.ppfeaturemask=0xffffffff"; then
            rpm-ostree kargs --append=amdgpu.ppfeaturemask=0xffffffff
            echo "${green}Added amdgpu.ppfeaturemask=0xffffffff to kernel arguments  ${reset}"
        else
            echo "${green}amdgpu.ppfeaturemask=0xffffffff already part of kernel arguments ${reset}"
        fi
        
    elif [ "$bootloader" = "grub" ]; then
        if ! grep -Fq "amdgpu.ppfeaturemask=0xffffffff" /etc/default/grub; then
        
            sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
            echo "${green}Added amdgpu.ppfeaturemask=0xffffffff to kernel arguments  ${reset}"
            
        else
            echo "${green}amdgpu.ppfeaturemask=0xffffffff already part of kernel arguments ${reset}"
        fi
        
        "$update_bootloader"
    else
        echo "${red}Unable to add kernel argument(s) ${reset}"
    fi
    
else
    echo "${yellow}No AMD GPU detected ${reset}"
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"

# Adds package(s) to autostart
cp -v /usr/share/applications/org.corectrl.*.desktop "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop"

# Prints a conclusive message
echo "${green}CoreCtrl is now installed ${reset}"
