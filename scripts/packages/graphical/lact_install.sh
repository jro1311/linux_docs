#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Installs package(s) based on the package manager detected
if command -v pacman &> /dev/null; then
    echo "Detected: pacman"
    # Installs package(s)
    sudo pacman -Syu --needed --noconfirm lact
elif command -v apt &> /dev/null; then
    echo "Detected: apt"
    # Runs script to install flatpak
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    
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
    # Runs script to install flatpak
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/flatpak_install.sh"
    
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y lact
else
    echo "Unknown package manager"
    # Installs package(s)
    flatpak update -y && flatpak install flathub -y lact
fi

# Enables LACT on the system
sudo systemctl enable --now lactd

# Gets GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Detects the operating system and stores it in a variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    
    # Fallback to $os if ID_LIKE is missing
    os_like="${ID_LIKE:-$os}"
else
    echo "Unable to detect the operating system"
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
        # Checks if GRUB is installed
        if pacman -Q grub &> /dev/null; then
            echo "GRUB is installed"    
            # Checks for AMD GPU
            if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
                echo "AMD GPU detected"
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
            echo "GRUB is not installed"
            echo "CoreCtrl is now installed. Add kernel argument 'amdgpu.ppfeaturemask=0xffffffff' to enable Full AMD GPU control"
            exit 1
        fi
        ;;
    "debian"|"ubuntu")
        # Checks for AMD GPU
        if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
            echo "AMD GPU detected"
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
            echo "AMD GPU detected"
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
                # Checks if GRUB is installed
                if pacman -Q grub &> /dev/null; then
                    echo "GRUB is installed"
                    # Checks for AMD GPU
                    if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
                        echo "AMD GPU detected"
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
                    echo "GRUB is not installed"
                    echo "CoreCtrl is now installed. Add kernel argument 'amdgpu.ppfeaturemask=0xffffffff' to enable Full AMD GPU control"
                    exit 1
                fi
                ;;
            "debian"|"ubuntu debian")
                # Checks for AMD GPU
                if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
                    echo "AMD GPU detected"
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
                    echo "AMD GPU detected"
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
                echo "Unsupported distribution: $os"
                exit 1
                ;;
        esac
        ;;
esac

# Prints a conclusive message to end the script
echo "LACT is now installed. Full AMD GPU control will be enabled after reboot."
