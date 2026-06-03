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

detect_system

exclude_from_array "gaming_flatpaks" "Gaming Flatpaks"

result=$(select_gpu_config_tool)
gpu_config_tool="${result%%|*}"
gpu_config_tool_uc="${result#*|}"

print_field "GPU Configuration Tool" "$gpu_config_tool_uc"
confirm_proceed

remove_non_selected_pkg "gpu_config_tool" "$gpu_config_tool" "${!gpu_config_tool_native_pkgs[@]}"

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
    apt)    sudo dpkg --add-architecture i386 && sudo apt-get update ;;
    zypper) ensure_pkg "selinux-policy-targeted-gaming" ;;
esac

case "$primary_pm" in
    rpm-ostree) ;;
    *) ensure_pkg "steam" ;;
esac

if install_mangohud; then
    configure_mangohud
fi

if [ "$flatpak_installed" -eq 1 ]; then
    configure_flatpak

    if [ "${#gaming_flatpaks[@]}" -ne 0 ]; then
        install_flatpak_pkg_bypass "${gaming_flatpaks[@]}"
    fi

    case "$primary_pm" in
        rpm-ostree) install_flatpak_pkg_bypass "com.valvesoftware.Steam" ;;
    esac

    # Grants read-only access to MangoHud's config file
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
    flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher
fi
