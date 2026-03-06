#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
reset=$(tput sgr0)

if ! command -v curl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then

    # Define primary package manager
    primary_package_manager="unknown"
    primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)

    for cmd in "${primary_package_managers[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            primary_package_manager="$cmd"
            break
        fi
    done

    # Normalizes xbps-install to xbps
    if [ "$primary_package_manager" = "xbps-install" ]; then
        primary_package_manager="xbps"
    fi

    if [ "$primary_package_manager" != "unknown" ]; then
        echo "${green}Primary Package Manager: $primary_package_manager ${reset}"
    fi

    packages=("curl" "jq")

    case $primary_package_manager in
        "apt")
            sudo apt-get install -y "${packages[@]}"
            ;;
        "dnf")
            sudo dnf install -y "${packages[@]}"
            ;;
        "eopkg")
            sudo eopkg install -y "${packages[@]}"
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm "${packages[@]}"
            ;;
        "xbps")
            sudo xbps-install -Sy "${packages[@]}"
            ;;
        "zypper")
            sudo zypper in -y "${packages[@]}"
            ;;
        "rpm-ostree")
            if ! command -v "${packages[@]}" >/dev/null 2>&1; then
                sudo rpm-ostree install "${packages[@]}"
                echo "${yellow}Reboot and run script again to complete. ${reset}"
                exit 0
            fi
            ;;
        *)
            echo "${red}Unsupported package manager. ${reset}"
            exit 1
            ;;
    esac
fi

# Define coordinates
location=$(curl -s "http://ipinfo.io/$(curl -s api.ipify.org)/json")
latitude=$(echo "$location" | jq -r '.loc' | cut -d',' -f1)
longitude=$(echo "$location" | jq -r '.loc' | cut -d',' -f2)

# Fetchs current temperature using coordinates
temperature=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m&temperature_unit=fahrenheit" | jq -r '.current.temperature_2m')

# Checks if temperature is empty or null
if [ -z "$temperature" ] || [ "$temperature" = "null" ]; then
    echo "${red}Unable to gather weather data. ${reset}"
    exit 1
fi

# Rounds temperature to the nearest whole number
temperature=$(printf "%.0f" "$temperature")

# Checks temperature and prints it
if [[ $temperature -le 40 ]]; then
    echo "Temperature:${blue} $temperature°F ${reset}"

elif [[ $temperature -le 80 ]]; then
    echo "Temperature:${green} $temperature°F ${reset}"

elif [[ $temperature -le 90 ]]; then
    echo "Temperature:${yellow} $temperature°F ${reset}"

elif [[ $temperature -gt 90 ]]; then
    echo "Temperature:${red} $temperature°F ${reset}"
fi
