#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

ld_bash_dir="$HOME/Documents/linux_docs/configs/system/bash/bash.d"

shopt -s nullglob globstar
for file in "$ld_bash_dir"/**/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done
shopt -u nullglob globstar

if command -v tput >/dev/null 2>&1; then
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    yellow=$(tput setaf 3)
    blue=$(tput setaf 4)
    reset=$(tput sgr0)
else
    red=$'\033[31m'
    green=$'\033[32m'
    yellow=$'\033[33m'
    blue=$'\033[34m'
    reset=$'\033[0m'
fi

ensure_pkg "curl" "jq"

get_location

time_12=$(date "+%I:%M %p")
time_24=$(date "+%H:%M")

weather_data=$(curl -sS \
  "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true&temperature_unit=fahrenheit&hourly=uv_index")

weather_code=$(echo "$weather_data" | jq -r '.current_weather.weathercode')
temperature_f=$(echo "$weather_data" | jq -r '.current_weather.temperature')

current_time=$(echo "$weather_data" | jq -r '.current_weather.time')
current_hour="${current_time%:*}:00"

uv_index=$(echo "$weather_data" | jq -r --arg t "$current_hour" '
  .hourly | (.time | index($t)) as $i | .uv_index[$i]
')

case "$weather_code" in
    0)          weather_condition="Sunny ☀️" ;;
    1)          weather_condition="Mostly Clear 🌤️" ;;
    2)          weather_condition="Partly Cloudy 🌤️" ;;
    3)          weather_condition="Overcast ☁️" ;;
    45|48)      weather_condition="Foggy ☁️" ;;
    51|53|55)   weather_condition="Drizzle 🌧️" ;;
    56|57)      weather_condition="Freezing Drizzle 🌧️" ;;
    61|63|65)   weather_condition="Rain 🌧️" ;;
    66|67)      weather_condition="Freezing Rain 🌧️" ;;
    71|73|75)   weather_condition="Snow 🌨️" ;;
    77)         weather_condition="Snow Grains 🌨️" ;;
    80|81|82)   weather_condition="Rain Showers 🌧️" ;;
    85|86)      weather_condition="Snow Showers 🌨️" ;;
    95|96|99)   weather_condition="Thunderstorm ⛈️" ;;
    *)          weather_condition="Unknown" ;;
esac

echo "Time: $time_12 ($time_24)"
echo "Weather: $weather_condition"

temperature_c=$(echo "($temperature_f - 32) * 5 / 9" | bc -l)

temperature_f=$(printf "%.0f" "$temperature_f")
temperature_c=$(printf "%.0f" "$temperature_c")

if [ "$temperature_f" -le 40 ]; then
    echo "Temperature:${blue} $temperature_f°F ($temperature_c°C) ${reset}"

elif [ "$temperature_f" -le 80 ]; then
    echo "Temperature:${green} $temperature_f°F ($temperature_c°C) ${reset}"

elif [ "$temperature_f" -le 90 ]; then
    echo "Temperature:${yellow} $temperature_f°F ($temperature_c°C) ${reset}"

elif [ "$temperature_f" -gt 90 ]; then
    echo "Temperature:${red} $temperature_f°F ($temperature_c°C) ${reset}"

else
    echo "Temperature: Unknown"
fi

if [ -z "$uv_index" ] || [ "$uv_index" = "null" ]; then
    echo "UV Index: Unknown"
    exit 0
fi

uv_index=$(printf "%.0f" "$uv_index")

if [ "$uv_index" -le 2 ]; then
    echo "UV Index:${green} $uv_index (Low) ${reset}"

elif [ "$uv_index" -le 5 ]; then
    echo "UV Index:${yellow} $uv_index (Moderate) ${reset}"

elif [ "$uv_index" -ge 6 ]; then
    echo "UV Index:${red} $uv_index (High) ${reset}"

else
    echo "UV Index: Unknown"
fi
