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

# Packages
packages=("corectrl")

# Checks for package manager
if command -v apt > /dev/null 2>&1; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get install -y "${packages[@]}"
    
elif command -v dnf > /dev/null 2>&1; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf install -y "${packages[@]}"
    
elif command -v pacman > /dev/null 2>&1; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
elif command -v xbps-install > /dev/null 2>&1; then
    echo "Detected: xbps"
    # Installs package(s)
    sudo xbps-install -Sy "${packages[@]}"
    
elif command -v zypper > /dev/null 2>&1; then
    echo "Detected: zypper"
    if [ "$os" = "opensuse-tumbleweed" ]; then
        # Adds repo(s)
        sudo zypper addrepo https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Tumbleweed/home:Dead_Mozay.repo
        # Installs package(s)
        sudo zypper in -y "${packages[@]}"
    elif [ "$os" = "opensuse-slowroll" ]; then
        # Adds repo(s)
        sudo zypper addrepo https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Slowroll/home:Dead_Mozay.repo
        # Installs package(s)
        sudo zypper in -y "${packages[@]}"
    else
        echo "Unsupported operating system"
        exit 1
    fi
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    echo "Detected: rpm-ostree"
    # Installs package(s)
    sudo rpm-ostree install "${packages[@]}"

else
    echo "Unsupported package manager"
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
        # Adds kernel argument(s)
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
        
        # Updates GRUB configuration
        if command -v update-grub > /dev/null 2>&1; then
            sudo update-grub
        elif command -v grub2-mkconfig > /dev/null 2>&1; then
            sudo grub2-mkconfig -o /boot/grub2/grub.cfg
        elif command -v grub-mkconfig > /dev/null 2>&1; then
            sudo grub-mkconfig -o /boot/grub/grub.cfg
        fi
    else
        echo "No AMD GPU detected"
    fi
else
    echo "GRUB not detected"
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"

# Adds package(s) to autostart
cp -v /usr/share/applications/org.corectrl.*.desktop "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop"

# Prints a conclusive message
echo "CoreCtrl is now installed"
