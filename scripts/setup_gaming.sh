#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

bashd_dir="$HOME/Documents/linux_docs/configs/system/bash/bashrc.d"

for file in "$bashd_dir"/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done

for dir in helpers configure_packages install_packages; do
    for file in "$bashd_dir/$dir"/*.sh; do
        [ -e "$file" ] || continue
        . "$file"
    done
done

detect_system

exclude_from_array gaming_flatpaks "Gaming Flatpaks"

result=$(select_gpu_config_tool)
gpu_config_tool="${result%%|*}"
gpu_config_tool_uc="${result#*|}"

print_field "GPU Configuration Tool" "$gpu_config_tool_uc"
confirm_proceed

case "$gpu_config_tool" in
    lact)
        if install_lact; then
            configure_lact
        fi
        ;;
    corectrl)
        if install_corectrl; then
            configure_corectrl
        fi
        ;;
esac

case "$primary_pm" in
    apt) sudo dpkg --add-architecture i386 && sudo apt-get update ;;
    zypper) install_pm_pkg_bypass "selinux-policy-targeted-gaming" ;;
esac

case "$primary_pm" in
    rpm-ostree) ;;
    *) install_pm_pkg_bypass "${steam_pkg[$primary_pm]}" ;;
esac

if install_mangohud; then
    configure_mangohud
fi

if [ "$flatpak_installed" -eq 1 ]; then
    configure_flatpak
    install_flatpak_pkg_bypass "${gaming_flatpaks[@]}" 

    case "$primary_pm" in
        rpm-ostree) install_flatpak_pkg_bypass "com.valvesoftware.Steam" ;;
    esac

    # Grants read-only access to MangoHud's config file
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
    flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher
fi
