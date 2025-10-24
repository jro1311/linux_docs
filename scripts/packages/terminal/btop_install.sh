#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Define primary package manager
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
if command -v snap > /dev/null 2>&1; then
    secondary_package_manager="snap"
    echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
    
else
    secondary_package_manager="unknown"
fi

# List of packages
packages=("btop")
snaps=("btop")

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then
    sudo apt-get install -y "${packages[@]}"
    
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
        echo "Detected GPU: AMD"
        sudo apt-get install -y rocm-smi
    fi

elif [ "$primary_package_manager" = "dnf" ]; then
    sudo dnf install -y "${packages[@]}"
    
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
        echo "Detected GPU: AMD"
        sudo dnf install -y rocm-smi
    fi

elif [ "$primary_package_manager" = "pacman" ]; then
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
        echo "Detected GPU: AMD"
        sudo pacman -S --needed --noconfirm rocm-smi-lib
    fi
    
elif [ "$primary_package_manager" = "xbps" ]; then
    sudo xbps-install -Sy "${packages[@]}"
    
    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
        echo "Detected GPU: AMD"
        sudo xbps-install -y ROCm-SMI
    fi

elif [ "$primary_package_manager" = "zypper" ]; then
    sudo zypper in -y "${packages[@]}"
    
elif [ "$secondary_package_manager" = "snap" ]; then
    sudo snap install "${snaps[@]}"
    
elif [ "$primary_package_manager" = "rpm-ostree" ]; then

    if command -v toolbox > /dev/null 2>&1; then
        toolbox_managers=(apt dnf pacman xbps zypper)

        for toolbox_manager in "${toolbox_managers[@]}"; do
            case "$toolbox_manager" in
                "apt")
                    if toolbox run command -v apt > /dev/null 2>&1; then
                        toolbox run sudo apt-get install -y "${packages[@]}"

                        # Checks for AMD GPU
                        if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
                            echo "Detected GPU: AMD"
                            toolbox run sudo apt-get install -y rocm-smi
                        fi
                    fi
                    ;;
                "dnf")
                    if toolbox run command -v dnf > /dev/null 2>&1; then
                        toolbox run sudo dnf install -y "${packages[@]}"

                        # Checks for AMD GPU
                        if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
                            echo "Detected GPU: AMD"
                            toolbox run sudo dnf install -y rocm-smi
                        fi
                    fi
                    ;;
                "pacman")
                    if toolbox run command -v pacman > /dev/null 2>&1; then
                        toolbox run sudo pacman -S --needed --noconfirm "${packages[@]}"

                        # Checks for AMD GPU
                        if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
                            echo "Detected GPU: AMD"
                            toolbox run sudo pacman -S --needed --noconfirm rocm-smi-lib
                        fi
                    fi
                    ;;
                "xbps")
                    if toolbox run command -v xbps-install > /dev/null 2>&1; then
                        toolbox run sudo xbps-install -Sy "${packages[@]}"

                        # Checks for AMD GPU
                        if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
                            echo "Detected GPU: AMD"
                            toolbox run sudo pacman -S --needed --noconfirm ROCm-SMI
                        fi
                    fi
                    ;;
                "zypper")
                    if toolbox run command -v zypper se > /dev/null 2>&1; then
                        toolbox run sudo zypper in -y "${packages[@]}"
                    fi
                    ;;
            esac
        done

    else
        sudo rpm-ostree install "${packages[@]}"

        # Checks for AMD GPU
        if echo "$gpu_info" | grep -i "amd" > /dev/null 2>&1; then
            echo "Detected GPU: AMD"
            sudo rpm-ostree install -y rocm-smi
        fi
    fi
        
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/btop"
    
# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/btop.conf" "$HOME/.config/btop/"

# Prints a conclusive message
echo "${green}btop is now installed ${reset}"

