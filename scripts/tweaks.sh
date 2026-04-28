#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

. "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d/helpers/source.sh"
source_all "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d"

detect_system

ld_prefix="$HOME/Documents/linux_docs/scripts"

if [ "$primary_pm" != "apt" ]; then
    unsupported_package_manager
    exit 1
fi

if command -v librewolf >/dev/null 2>&1 \
    && confirm "Remove LibreWolf package to install flatpak version later? [y/N]"; then
    sudo apt-get remove -y librewolf
    sudo extrepo disable librewolf
fi

if command -v discord >/dev/null 2>&1 \
    && confirm "Remove Discord package to install flatpak version later? [y/N]"; then
    sudo apt-get remove -y discord
fi

confirm_proceed

sudo apt-get purge -y goverlay || true

if [ "$flatpak_installed" -eq 1 ]; then
    flatpak override --user --reset=xdg-config/MangoHud
    flatpak override --user --reset=GTK_THEME com.github.tchx84.Flatseal
fi

rm -rf "$HOME/Documents/MangoHud" 2>/dev/null || true
rm -rf "$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton"* 2>/dev/null || true
sed -i '/^# Updates system/,${/^# Updates system/d; d;}' "$HOME/.bashrc"

remove_kernel_parameter \
    "preempt=full" \
    "amdgpu.ppfeaturemask=0xffffffff"

add_kernel_parameter \
    "preempt=full"
    "amdgpu.ppfeaturemask=0xffffffff"

run_script "$ld_prefix/setup_system.sh"
