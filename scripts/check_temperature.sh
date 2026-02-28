#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
reset=$(tput sgr0)

# Fetchs current temperature using wttr.in (no API key required)
echo "Gathering data from wttr.in..."
temperature=$(curl -s "https://wttr.in/?format=%t" | grep -oE '[0-9]+')

# Checks temperature and prints it
if [[ $temperature -le 40 ]]; then
    echo "Temperature:${blue} $temperature°F ${reset}"

elif [[ $temperature -le 80 ]]; then
    echo "Temperature:${green} $temperature°F ${reset}"

elif [[ $temperature -le 90 ]]; then
    echo "Temperature:${yellow} $temperature°F ${reset}"

elif [[ $temperature -ge 90 ]]; then
    echo "Temperature:${red} $temperature°F ${reset}"
fi
