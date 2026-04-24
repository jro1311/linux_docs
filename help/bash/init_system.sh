#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# V1

# Define init system
init_system=""
init_names=(systemd dinit openrc-init runit s6-linux-init init)
pid1_comm=$(ps -p 1 -o comm=)

for init_name in "${init_names[@]}"; do
    if [ "$pid1_comm" = "$init_name" ]; then
        init_system="$init_name"
        break
    fi
done

case "$pid1_comm" in
    "openrc-init")
        init_system="openrc"
        ;;
    "s6-linux-init")
        init_system="s6"
        ;;
    "init")
        init_system="sysvinit"
        ;;
esac

if [ -n "$init_system" ]; then
    echo "${green}Init System:${reset} $init_system"
fi

# V2

# Define init system
init_system=""
pid1_comm=$(ps -p 1 -o comm=)

case "$pid1_comm" in
    "systemd"|"dinit"|"runit")
        init_system="$pid1_comm"
        ;;
    "openrc-init")
        init_system="openrc"
        ;;
    "s6-linux-init")
        init_system="s6"
        ;;
    "init")
        init_system="sysvinit"
        ;;
esac

if [ -n "$init_system" ]; then
    echo "${green}Init System:${reset} $init_system"
fi

# Checks for init system and enables service
case "$init_system" in
    "systemd")
        sudo systemctl enable --now package
        ;;
    "dinit")
        sudo ln -s /etc/dinit.d/package /etc/dinit.d/boot.d/
        ;;
    "openrc")
        sudo rc-service package start
        sudo rc-update add package
        ;;
    "runit")
        sudo ln -s /etc/sv/package /var/service
        ;;
    "s6")
        sudo ln -s /etc/s6/sv/package /var/service/
        ;;
    "sysvinit")
        sudo update-rc.d package enable
        sudo service package start
        ;;
    *)
        echo "${red}Unsupported init system.${reset}"
        exit 1
        ;;
esac
