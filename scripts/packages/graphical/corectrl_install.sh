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

# List of packages
packages=("corectrl")

# Checks for main package manager and installs package(s)
if [ "$main_package_manager" = "apt" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo apt-get install -y "${packages[@]}"
    
elif [ "$main_package_manager" = "dnf" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo dnf install -y "${packages[@]}"
    
elif [ "$main_package_manager" = "pacman" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
elif [ "$main_package_manager" = "xbps" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo xbps-install -Sy "${packages[@]}"
    
elif [ "$main_package_manager" = "zypper" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
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
    
elif [ "$main_package_manager" = "rpm-ostree" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
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

# Checks for file
if [ -f /etc/default/grub ]; then
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -iq "amd"; then
        echo "${green}Detected GPU: AMD ${reset}"
        # Adds kernel argument(s)
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
        
        # Updates GRUB configuration
        if command -v update-grub > /dev/null 2>&1; then
            echo "${green}Detected Bootloader: GRUB ${reset}"
            sudo update-grub
            
        elif command -v grub2-mkconfig > /dev/null 2>&1; then
            echo "${green}Detected Bootloader: GRUB ${reset}"
            sudo grub2-mkconfig -o /boot/grub2/grub.cfg
            
        elif command -v grub-mkconfig > /dev/null 2>&1; then
            echo "${green}Detected Bootloader: GRUB ${reset}"
            sudo grub-mkconfig -o /boot/grub/grub.cfg
        fi
        
    else
        echo "{$yellow}No AMD GPU detected {$reset}"
    fi
    
else
    echo "{$yellow}GRUB not detected {$reset}"
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"

# Adds package(s) to autostart
cp -v /usr/share/applications/org.corectrl.*.desktop "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop"

# Prints a conclusive message
echo "${green}CoreCtrl is now installed ${reset}"
