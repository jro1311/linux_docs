#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for package
if ! command -v git > /dev/null 2>&1; then

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
    
    # List of packages
    packages=("git")

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
        sudo zypper in -y "${packages[@]}"
        
    elif [ "$primary_package_manager" = "rpm-ostree" ]; then

        if command -v toolbox > /dev/null 2>&1; then
            toolbox_managers=(apt dnf pacman xbps zypper)

            for toolbox_manager in "${toolbox_managers[@]}"; do
                case "$toolbox_manager" in
                    "apt")
                        if toolbox run command -v apt > /dev/null 2>&1; then
                            toolbox run sudo apt-get install -y "${packages[@]}"
                        fi
                        ;;
                    "dnf")
                        if toolbox run command -v dnf > /dev/null 2>&1; then
                            toolbox run sudo dnf install -y "${packages[@]}"
                        fi
                        ;;
                    "pacman")
                        if toolbox run command -v pacman > /dev/null 2>&1; then
                            toolbox run sudo pacman -S --needed --noconfirm "${packages[@]}"
                        fi
                        ;;
                    "xbps")
                        if toolbox run command -v xbps-install > /dev/null 2>&1; then
                            toolbox run sudo xbps-install -Sy "${packages[@]}"
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
            echo "${yellow}Reboot and run script again to complete ${reset}"
            exit 0
        fi
        
    else
        echo "${red}Unsupported package manager${reset}"
        exit 1
    fi
fi

# Define the source and base directories
source_dir="$HOME/Documents/linux_docs"
base_dir="$HOME/Documents/linux_docs_old"

# Checks for directory
if [ -d "$base_dir" ]; then

    # Use numbered naming logic
    count=1
    new_dir="$base_dir"
    while [ -d "$new_dir" ]; do
        new_dir="$base_dir$count"
        count=$((count + 1))
    done
    
    # Renames directory(s)
    mv -v "$source_dir" "$new_dir"

else
    # Renames directory(s)
    mv -v "$source_dir" "$base_dir"
fi

# Clones git repository
git clone https://github.com/jro1311/linux_docs.git "$source_dir"

# Enables nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Function for user input
get_answer() {
    while true; do
        read -r -p "Remove linux_docs_old directory(s)? [Y/n]: " answer
        answer="${answer:-y}"
        case "$answer" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Enter a 'y' or 'n'";;
        esac
    done
}

# Checks for answer
if get_answer; then
    rm -rf "$HOME/Documents/linux_docs_old"*
fi

# Runs script to make all scripts executable
chmod +x "$HOME/Documents/linux_docs/scripts/functions/chmod_scripts.sh"
"$HOME/Documents/linux_docs/scripts/functions/chmod_scripts.sh"

# Print a conclusive message
echo "${green}Git clone complete ${reset}"
