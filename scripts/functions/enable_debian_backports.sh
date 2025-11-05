#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
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
    echo "${red}Unable to detect the operating system. ${reset}"
    exit 1
fi

# Executes commands based on the operating system
case "$os" in
    "debian")
        # Converts old sources.list format into modern debian.sources format
        sudo apt modernize-sources -y

        # Checks for backports repository
        if ! grep -Fq "backports" /etc/apt/sources.list.d/debian.sources; then

            # Adds repo(s)
            version="$(lsb_release -cs)"
            sed -i "/Suites:/ s/version-backports/${version}-backports/" /etc/apt/sources.list.d/debian.sources
            sudo apt-get update

        fi
        ;;
    "ubuntu")
        echo "${red}Unsupported operating system. ${reset}"
        exit 1
        ;;
    *)
        case "$os_like" in
            "debian")
                # Converts old sources.list format into modern debian.sources format
                sudo apt modernize-sources -y

                # Checks for backports sources file
                if [ ! -f /etc/apt/sources.list.d/debian_backports.sources ]; then

                    # Copies config(s)
                    sudo cp -v "$HOME/Documents/linux_docs/configs/system/debian_backports.sources" /etc/apt/sources.list.d/

                    # Adds repo(s)
                    version="$(lsb_release -cs)"
                    sed -i "/Suites:/ s/version-backports/${version}-backports/" /etc/apt/sources.list.d/debian_backports.sources
                    sudo apt-get update

                fi
                ;;
            *)
                echo "${red}Unsupported operating system. ${reset}"
                exit 1
        esac
    ;;
esac

# Prints a conclusive message
echo "${green}Enabled Debian backports repository. ${reset}"
