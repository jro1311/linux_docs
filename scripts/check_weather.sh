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
    [[ -f "$rc" ]] && source "$rc"
done
unset rc
shopt -u globstar nullglob

# Checks that packages are installed
packages=("curl" "jq")
for package in "${packages[@]}"; do
    inverse_check "$package" \
        install_packages "$package"
done

# Define coordinates
if [ -f "$HOME/Documents/location_info.conf" ]; then
    source "$HOME/Documents/location_info.conf"
    latitude="$lat"
    longitude="$long"
else
    location=$(curl -sS http://ip-api.com/json)
    latitude=$(echo "$location" | jq -r '.lat')
    longitude=$(echo "$location" | jq -r '.lon')

    if [ "$latitude" = "null" ] || [ "$longitude" = "null" ]; then
        red_message "Error:" "Failed to get coordinates."
        exit 1
    fi

    echo "lat=$latitude" | tee -a "$HOME/Documents/location_info.conf"
    echo "long=$longitude" | tee -a "$HOME/Documents/location_info.conf"
fi

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
