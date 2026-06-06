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

if [ "$primary_pm" != "apt" ]; then
    unsupported_pkg_manager
    exit 1
fi

if pkg_installed_pm "librewolf" \
    && confirm "Remove LibreWolf package to install flatpak version later? [y/N]"; then
    sudo apt-get purge -y librewolf
    sudo extrepo disable librewolf
fi

if pkg_installed_pm "discord" \
    && confirm "Remove Discord package to install flatpak version later? [y/N]"; then
    sudo apt-get purge -y discord
fi

confirm_proceed

sudo apt-get purge -y goverlay winetricks wine* winehq* || :
sudo rm -f /etc/apt/sources.list.d/winehq*.list
rm -rf "$HOME/.wine" \
       "$HOME/.local/share/wine" \
       "$HOME/.local/share/applications/wine"

rm -rf "$HOME/Documents/MangoHud"
rm -rf "$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton"*
rm -rf "$HOME/.steam/steam/steamapps/shadercache/"*

if [ "$flatpak_installed" -eq 1 ]; then
    flatpak override --user --reset=xdg-config/MangoHud
    flatpak override --user --reset=GTK_THEME com.github.tchx84.Flatseal
fi

sed -i '/^# Updates system/,${/^# Updates system/d; d;}' "$HOME/.bashrc"

remove_kernel_parameter \
    "preempt=full" \
    "amdgpu.ppfeaturemask=0xffffffff"

add_kernel_parameter \
    "preempt=full"
    "amdgpu.ppfeaturemask=0xffffffff"

run_script "$LD_SCR/system/setup_system.sh"
