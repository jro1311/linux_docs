#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Detects the operating system and stores it in a variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "Unable to detect the operating system"
    read -p "Press enter to exit"
    exit 1
fi

# Converts the variable into lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Prints the detected operating system
echo "Detected (ID): $os"
echo "Detected (ID_LIKE): $os_like"

# Creates an autostart directory if it doesn't already exist
mkdir -pv "$HOME/.config/autostart"

# Installs package(s) based on the package manager detected
if command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y corectrl
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y corectrl
elif command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm corectrl
elif command -v rpm-ostree &> /dev/null; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    sudo rpm-ostree upgrade && sudo rpm-ostree install corectrl
elif command -v xbps-install &> /dev/null; then
    echo "Detected: xbps"
    # Installs package(s)
    sudo xbps-install -Suy xbps && sudo xbps-install -uy && sudo xbps-install -y corectrl
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    if [ "$os" = "opensuse-tumbleweed" ]; then
        sudo zypper addrepo https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Tumbleweed/home:Dead_Mozay.repo
        sudo zypper ref && sudo zypper dup && sudo zypper in -y corectrl
    elif [ "$os" = "opensuse-slowroll" ]; then
        sudo zypper addrepo https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Slowroll/home:Dead_Mozay.repo
        sudo zypper ref && sudo zypper dup && sudo zypper in -y corectrl
    else
        echo "Unsupported operating system"
        read -p "Press enter to exit"
        exit 1
    fi
        
    # Adds package(s) to autostart
    cp -v /usr/share/applications/org.corectrl.CoreCtrl.desktop "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop"
else
    echo "Unsupported package manager"
    read -p "Press enter to exit"
    exit 1
fi

# Gets the current user's primary group and stores it in a variable
group=$(id -gn)

# Generates a CoreCtrl polkit rule file with the current user's primary group
echo "polkit.addRule(function(action, subject) {
    if ((action.id == 'org.corectrl.helper.init' ||
         action.id == 'org.corectrl.helperkiller.init') &&
        subject.local == true &&
        subject.active == true &&
        subject.isInGroup('$group')) {
            return polkit.Result.YES;
    }
});" | sudo tee /etc/polkit-1/rules.d/90-corectrl.rules

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for file
if [ -f /etc/default/grub ]; then
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
        # Adds kernel argument(s)
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
        
        # Updates GRUB configuration
        if command -v update-grub &> /dev/null; then
            sudo update-grub
        elif command -v grub2-mkconfig &> /dev/null; then
            sudo grub2-mkconfig -o /boot/grub2/grub.cfg
        elif command -v grub-mkconfig &> /dev/null; then
            sudo grub-mkconfig -o /boot/grub/grub.cfg
        fi
    fi
else
    echo "GRUB not detected"
fi

# Checks for file and adds it to autostart
if [ -f /usr/share/applications/org.corectrl.CoreCtrl.desktop ]; then
    cp -v /usr/share/applications/org.corectrl.CoreCtrl.desktop "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop"
elif [ -f /usr/share/applications/org.corectrl.corectrl.desktop ]; then
    cp /usr/share/applications/org.corectrl.corectrl.desktop "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop"
fi

# Prints a conclusive message
echo "CoreCtrl is now installed"
read -p "Press enter to exit"

