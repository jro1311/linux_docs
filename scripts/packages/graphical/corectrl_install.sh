#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Creates an autostart directory if it doesn't already exist
mkdir -pv "$HOME/.config/autostart"

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm corectrl
        
    # Adds package(s) to autostart
    cp -v /usr/share/applications/org.corectrl.CoreCtrl.desktop "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop"
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y corectrl
        
    # Adds package(s) to autostart
    cp /usr/share/applications/org.corectrl.corectrl.desktop "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop"
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y corectrl
        
    # Adds package(s) to autostart
    cp -v /usr/share/applications/org.corectrl.CoreCtrl.desktop "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop"
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Adds repo(s)
    sudo zypper addrepo https://download.opensuse.org/repositories/home:Dead_Mozay/openSUSE_Tumbleweed/home:Dead_Mozay.repo
        
    # Installs package(s)
    sudo zypper ref && sudo zypper dup -y && sudo zypper in -y corectrl
        
    # Adds package(s) to autostart
    cp -v /usr/share/applications/org.corectrl.CoreCtrl.desktop "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop"
else
    echo "Unknown package manager"
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

# Detects the operating system and stores it in a variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "Unable to detect the operating system."
    exit 1
fi

# Converts the variable into lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Prints the detected operating system
echo "Detected (ID): $os"
echo "Detected (ID_LIKE): $os_like"

# Installs packages based on the detected operating system
case "$os" in
    "arch")
        # Checks for GRUB
        if pacman -Q grub &> /dev/null; then
            echo "Detected Bootloader: GRUB"
            # Checks for AMD GPU
            if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
                echo "Detected GPU: AMD"
                # Adds kernel argument(s)
                sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
                    
                # Displays the contents of /etc/default/grub
                cat /etc/default/grub
    
                # Updates GRUB configuration
                sudo grub2-mkconfig
            else
                echo "No AMD GPU detected"
            fi
        else
            echo "GRUB not detected"
            echo "CoreCtrl is now installed"
            echo "Add kernel argument 'amdgpu.ppfeaturemask=0xffffffff' to enable Full AMD GPU control"
            read -p "Press enter to exit"
            exit 1
        fi
        ;;
    "debian"|"ubuntu")
        # Checks for AMD GPU
        if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
            echo "Detected GPU: AMD"
            # Adds kernel argument(s)
            sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
                    
            # Displays the contents of /etc/default/grub
            cat /etc/default/grub
    
            # Updates GRUB configuration
            sudo update-grub
        else
            echo "No AMD GPU detected"
        fi
        ;;
    "fedora"|"opensuse")
        # Checks for AMD GPU
        if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
            echo "Detected GPU: AMD"
            # Adds kernel argument(s)
            sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
                    
            # Displays the contents of /etc/default/grub
            cat /etc/default/grub
    
            # Updates GRUB configuration
            sudo grub2-mkconfig
        else
            echo "No AMD GPU detected"
        fi
        ;;
    *)
        case "$os_like" in
            "arch")
                # Checks for GRUB
                if pacman -Q grub &> /dev/null; then
                    echo "Detected Bootloader: GRUB"
                    # Checks for AMD GPU
                    if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
                        echo "Detected GPU: AMD"
                        # Adds kernel argument(s)
                        sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
                    
                        # Displays the contents of /etc/default/grub
                        cat /etc/default/grub
    
                        # Updates GRUB configuration
                        sudo grub2-mkconfig
                    else
                        echo "No AMD GPU detected"
                    fi
                else
                    echo "GRUB not detected"
                    echo "CoreCtrl is now installed"
                    echo "Add kernel argument 'amdgpu.ppfeaturemask=0xffffffff' to enable Full AMD GPU control"
                    read -p "Press enter to exit"
                    exit 1
                fi
                ;;
            "debian"|"ubuntu debian")
                # Checks for AMD GPU
                if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
                    echo "Detected GPU: AMD"
                    # Adds kernel argument(s)
                    sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
                    
                    # Displays the contents of /etc/default/grub
                    cat /etc/default/grub
                    
                    # Updates GRUB configuration
                    sudo update-grub
                else
                    echo "No AMD GPU detected"
                fi
                ;;
            "fedora"|"opensuse")
                # Checks for AMD GPU
                if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
                    echo "Detected GPU: AMD"
                    # Adds kernel argument(s)
                    sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
                    
                    # Displays the contents of /etc/default/grub
                    cat /etc/default/grub
    
                    # Updates GRUB configuration
                    sudo grub2-mkconfig
                else
                    echo "No AMD GPU detected"
                fi
                ;;
            *)
                echo "Unsupported distribution"
                read -p "Press enter to exit"
                exit 1
                ;;
        esac
        ;;
esac

# Prints a conclusive message
echo "CoreCtrl is now installed"
echo "Full AMD GPU control will be enabled after reboot"
read -p "Press enter to exit"

