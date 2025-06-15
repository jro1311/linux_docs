#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for flatpak and flathub
if ! command -v flatpak &> /dev/null || ! flatpak remote-list | grep -q "flathub"; then
    # Runs script to install flatpak and set up flathub
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
fi

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm lact
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y lact
elif command -v dnf &> /dev/null; then
    echo "Detected: dnf"
    # Adds repo(s)
    sudo dnf copr enable -y ilyaz/LACT
            
    # Installs package(s)
    sudo dnf upgrade -y && sudo dnf install -y lact
elif command -v zypper &> /dev/null; then
    echo "Detected: zypper"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y lact
elif command -v xbps-install &> /dev/null; then
    echo "Detected: xbps"
    # Installs package(s)
    sudo xbps-install -u -y && sudo xbps-install -y LACT
else
    echo "Unsupported package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y lact
fi

# Checks for init system
if ps -p 1 -o comm= | grep -q "systemd"; then
    echo "Detected: systemd"
    # Enables LACT
    sudo systemctl enable --now lactd
elif ps -p 1 -o comm= | grep -q "runit"; then
    echo "Detected: runit"
    # Enables LACT
    sudo ln -s /etc/sv/lactd /var/service
else
    echo "Unsupported init system"
    read -p "Press enter to exit"
    exit 1
fi

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

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
            exit 
        fi
        ;;
    "debian"|"ubuntu"|"void")
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
    "fedora"|"opensuse"|"openmandriva")
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
echo "LACT is now installed"
echo "Full AMD GPU control will be enabled after reboot"
read -p "Press enter to exit"
