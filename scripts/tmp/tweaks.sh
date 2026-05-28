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

ld_prefix="$HOME/Documents/linux_docs/scripts"

if [ "$primary_pm" != "apt" ]; then
    unsupported_pkg_manager
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

sudo apt-get purge -y goverlay || :

if [ "$flatpak_installed" -eq 1 ]; then
    flatpak override --user --reset=xdg-config/MangoHud
    flatpak override --user --reset=GTK_THEME com.github.tchx84.Flatseal
fi

rm -rf "$HOME/Documents/MangoHud"
rm -rf "$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton"*
rm -rf "$HOME/.steam/steam/steamapps/shadercache/"*

sed -i '/^# Updates system/,${/^# Updates system/d; d;}' "$HOME/.bashrc"

sudo mount -o remount,compress=zstd:1 /
sudo sed -i 's/compress-force/compress/g' /etc/fstab

remove_kernel_parameter \
    "preempt=full" \
    "amdgpu.ppfeaturemask=0xffffffff"

add_kernel_parameter \
    "preempt=full"
    "amdgpu.ppfeaturemask=0xffffffff"

run_script "$ld_prefix/setup_system.sh"
