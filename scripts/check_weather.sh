#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
reset=$(tput sgr0)

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f $rc ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob

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
        green_message "Primary Package Manager:" "$primary_package_manager"
    fi

    packages=("curl" "jq")
    install_packages "${packages[@]}"

fi

# Define coordinates
location=$(curl -sS "http://ipinfo.io/$(curl -s api.ipify.org)/json")
latitude=$(echo "$location" | jq -r '.loc' | cut -d',' -f1)
longitude=$(echo "$location" | jq -r '.loc' | cut -d',' -f2)

# Fetch current temperature, UV index, and weather condition using coordinates
weather_data=$(curl -sS "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,uv_index,weather_code&temperature_unit=fahrenheit")

weather_code=$(echo "$weather_data" | jq -r '.current.weather_code')
temperature_f=$(echo "$weather_data" | jq -r '.current.temperature_2m')
uv_index=$(echo "$weather_data" | jq -r '.current.uv_index')

# Converts weather code to a human-readable condition
case "$weather_code" in
    "0")
        weather_condition="☀️Sunny"
        ;;
    "1")
        weather_condition="🌤️Mostly Clear"
        ;;
    "2")
        weather_condition="🌤️Partly Cloudy"
        ;;
    "3")
        weather_condition="☁️Overcast"
        ;;
    "45"|"48")
        weather_condition="☁️Foggy"
        ;;
    "51"|"53"|"55")
        weather_condition="🌧️Drizzle"
        ;;
    "56"|"57")
        weather_condition="🌧️Freezing Drizzle"
        ;;
    "61"|"63"|"65")
        weather_condition="🌧️Rain"
        ;;
    "66"|"67")
        weather_condition="🌧️Freezing Rain"
        ;;
    "71"|"73"|"75")
        weather_condition="🌨️Snow"
        ;;
    "77")
        weather_condition="🌨️Snow Grains"
        ;;
    "80"|"81"|"82")
        weather_condition="⛈️Rain Showers"
        ;;
    "85"|"86")
        weather_condition="🌨️Snow Showers"
        ;;
    "95"|"96"|"99")
        weather_condition="⛈️Thunderstorm"
        ;;
    *)
        weather_condition="Unknown"
        ;;
esac

echo "Weather: $weather_condition"

# Converts Fahrenheit to Celsius
temperature_c=$(echo "($temperature_f - 32) * 5 / 9" | bc -l)

# Rounds temperatures to the nearest whole number
temperature_f=$(printf "%.0f" "$temperature_f")
temperature_c=$(printf "%.0f" "$temperature_c")

# Checks temperature and prints it
if [[ "$temperature_f" -le 40 ]]; then
    echo "Temperature:${blue} $temperature_f°F ($temperature_c°C) ${reset}"

elif [[ "$temperature_f" -le 80 ]]; then
    echo "Temperature:${green} $temperature_f°F ($temperature_c°C) ${reset}"

elif [[ "$temperature_f" -le 90 ]]; then
    echo "Temperature:${yellow} $temperature_f°F ($temperature_c°C) ${reset}"

elif [[ "$temperature_f" -gt 90 ]]; then
    echo "Temperature:${red} $temperature_f°F ($temperature_c°C) ${reset}"

else
    echo "Temperature: Unknown"
fi

# Rounds UV index to the nearest whole number
uv_index=$(printf "%.0f" "$uv_index")

# Checks UV index and prints it
if [[ "$uv_index" -le 2 ]]; then
    echo "UV Index:${green} $uv_index (Low) ${reset}"

elif [[ "$uv_index" -le 5 ]]; then
    echo "UV Index:${yellow} $uv_index (Moderate) ${reset}"

elif [[ "$uv_index" -ge 6 ]]; then
    echo "UV Index:${red} $uv_index (High) ${reset}"

else
    echo "UV Index: Unknown"
fi
