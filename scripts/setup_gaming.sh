#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# shellcheck disable=SC2044
# Sources all .sh files in bashrc.d
for rc in $(find "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d" -type f -name '*.sh' 2>/dev/null); do
    . "$rc"
done

detect_system

gpu_config_tool=""
gpu_config_tool_uc=""

green_message "GPU Configuration Tools:"
printf '%s\n' \
    "[1] LACT" \
    "[2] CoreCtrl" \
    "[x] none" | sed "s/^/  /"

while true; do
    read -r -p "Select tool [1-2]: " num

    case "$num" in
        1)
            gpu_config_tool="lact"
            gpu_config_tool_uc="LACT"
            ;;
        2)
            gpu_config_tool="corectrl"
            gpu_config_tool_uc="CoreCtrl"
            ;;
        x) ;;
        *) continue ;;
    esac

    break
done

print_field "GPU Configuration Tool" "$gpu_config_tool_uc"

confirm_proceed

case "$gpu_config_tool" in
    lact)     install_lact && configure_lact ;;
    corectrl) install_corectrl && configure_corectrl ;;
esac

case "$primary_pm" in
    apt)    sudo dpkg --add-architecture i386 && sudo apt-get update ;;
    zypper) install_pm_pkg_bypass "selinux-policy-targeted-gaming" ;;
esac

case "$primary_pm" in
    rpm-ostree) ;;
    *) install_pm_pkg_bypass "${steam_pkg[$primary_pm]}" ;;
esac

install_mangohud && configure_mangohud

if [ "$flatpak_installed" -eq 1 ]; then
    configure_flatpak
    flatpak install flathub -y "${gaming_flatpaks[@]}"

    case "$primary_pm" in
        rpm-ostree) flatpak install flathub -y com.valvesoftware.Steam ;;
    esac

    # Grants read-only access to MangoHud's config file
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
    flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher
fi
