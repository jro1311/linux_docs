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
print_system_info

ld_prefix="$HOME/Documents/linux_docs/scripts"

if [ "$primary_pm" != "apt" ]; then
    unsupported_package_manager
    exit 1
fi

if command -v librewolf >/dev/null 2>&1 \
    && confirm "Remove LibreWolf package to install flatpak version later? [y/N]"; then
    sudo apt-get remove -y librewolf || true
    sudo extrepo disable librewolf || true
fi

if command -v discord >/dev/null 2>&1 \
    && confirm "Remove Discord package to install flatpak version later? [y/N]"; then
    sudo apt-get remove -y discord || true
fi

confirm_proceed

sudo apt-get purge -y goverlay || true

if [ "$flatpak_installed" -eq 1 ]; then

    # Undo giving all flatpaks read-only permission to MangoHud's config file
    flatpak override --user --reset=xdg-config/MangoHud

    # Undo forcing Flatseal to use Adwaita Dark theme
    flatpak override --user --reset=GTK_THEME com.github.tchx84.Flatseal

fi

rm -rf "$HOME/Documents/MangoHud" 2>/dev/null || true
rm -rf "$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton"* 2>/dev/null || true

# Deletes old bashrc settings
sed -i '/^# Updates system/,${/^# Updates system/d; d;}' "$HOME/.bashrc"

remove_kernel_parameter \
    "preempt=full" \
    "amdgpu.ppfeaturemask=0xffffffff"

add_kernel_parameter \
    "preempt=full"
    "amdgpu.ppfeaturemask=0xffffffff"

run_script "$ld_prefix/setup_system.sh"
