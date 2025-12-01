#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# V1

# Define init system
init_system="unknown"
if ps -p 1 -o comm= | grep -Fq "systemd"; then
    init_system="systemd"

elif ps -p 1 -o comm= | grep -Fq "runit"; then
    init_system="runit"

elif ps -p 1 -o comm= | grep -Fq "sysvinit"; then
    init_system="sysvinit"

elif ps -p 1 -o comm= | grep -Fq "openrc-init"; then
    init_system="openrc-init"
fi

if [ "$init_system" != "unknown" ]; then
    echo "${green}Init System: $init_system ${reset}"
fi

# V2

# Define init system
init_system="unknown"
init_names=(systemd runit sysvinit openrc-init)
pid1_comm=$(ps -p 1 -o comm=)

for init_name in "${init_names[@]}"; do
    if [ "$pid1_comm" = "$init_name" ]; then
        init_system="$init_name"
        break
    fi
done

if [ "$init_system" != "unknown" ]; then
    echo "${green}Init System: $init_system ${reset}"
fi

# V3

pid1_comm=$(ps -p 1 -o comm=)
init_system="$pid1_comm"

# IF THEN

# Checks for init system and enables service
if [ "$init_system" = "systemd" ]; then
    sudo systemctl enable --now package.service

elif [ "$init_system" = "runit" ]; then
    sudo ln -s /etc/sv/package /var/service

else
    echo "{$red}Unsupported init system. ${reset}"
    exit 1
fi

# CASE

# Get init system
init_system=$(ps -p 1 -o comm=)

# Executes commands based on the init system
case "$init_system" in
    "systemd")
        echo "${green}Init System: $init_system ${reset}"
        ;;
    "runit")
        echo "${green}Init System: $init_system ${reset}"
        ;;
    "sysvinit")
        echo "${green}Init System: $init_system ${reset}"
        ;;
    "openrc-init")
        echo "${green}Init System: $init_system ${reset}"
        ;;
    *)
        echo "${red}Unsupported init system. ${reset}"
        exit 1
        ;;
esac
