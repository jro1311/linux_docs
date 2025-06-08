#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Refreshes package repositories and installs package(s)
sudo apt update && sudo apt install -y nala

# Removes package(s)
sudo nala purge -y corectrl goverlay
sudo rm -fv /etc/polkit-1/rules.d/90-corectrl.rules
rm -v "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop"

# Updates system 
sudo nala upgrade -y && flatpak update -y && cinnamon-spice-updater --update-all

# Installs package(s)
sudo nala install -y software-properties-common

# Adds repo(s)
sudo add-apt-repository multiverse

# Installs package(s)
sudo nala install -y btop btrfs-compsize btrfsmaintenance cpu-x curl dos2unix firefox flatpak fontconfig fzf git gsmartcontrol htop libavcodec-extra libdvd-pkg memtest86+ mintchat mint-meta-codecs mpv neofetch rocm-smi shellcheck smartmontools systemd-zram-generator tealdeer transmission-gtk ttf-mscorefonts-installer yt-dlp

# Installs package(s)
flatpak install flathub -y discordapp runtime/org.freedesktop.Platform.ffmpeg-full/x86_64/24.08 flatseal runtime/org.freedesktop.Platform.GStreamer.gstreamer-vaapi/x86_64/23.08 app/org.libreoffice.LibreOffice/x86_64/stable

# Installs package(s)
sudo nala install -y mangohud steam-installer
flatpak install flathub -y furmark lact runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08 mangojuice prismlauncher com.github.Matoking.protontricks/x86_64/stable

# Removes directory(s)
rm -rv "$HOME/Documents/MangoHud"

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"
mkdir -pv "$HOME/.config/btop"
mkdir -pv "$HOME/.config/fontconfig"
mkdir -pv "$HOME/.config/htop"
mkdir -pv "$HOME/.config/MangoHud"
mkdir -pv "$HOME/.config/mpv"
mkdir -pv "$HOME/.var/app/io.mpv.Mpv/config/mpv"
mkdir -pv "$HOME/Documents/mangohud/logs"

# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/btop.conf" "$HOME/.config/btop/"
cp -v "$HOME/Documents/linux_docs/configs/packages/fonts.conf" "$HOME/.config/fontconfig/"
cp -v "$HOME/Documents/linux_docs/configs/packages/htoprc" "$HOME/.config/htop/"
cp -v "$HOME/Documents/linux_docs/configs/packages/nanorc" "$HOME/.config/"
cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud.conf" "$HOME/.config/MangoHud/"
cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.config/"
cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/99-zram.conf" /etc/sysctl.d/
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram-generator.conf" /etc/systemd/

# Enables LACT
sudo systemctl enable --now lactd

# Undo giving all flatpaks read-only permission to MangoHud's config file
flatpak override --user --reset=xdg-config/MangoHud

# Undo forcing Flatseal to use Adwaita Dark theme
flatpak override --user --reset=GTK_THEME com.github.tchx84.Flatseal

# Grants only certain flatpaks read-only access to MangoHud's config
flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark 
flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher

# Configures system timer(s)
sudo systemctl disable btrfs-defrag.timer
sudo systemctl disable btrfs-trim.timer
sudo systemctl enable btrfs-balance.timer
sudo systemctl enable btrfs-scrub.timer
sudo systemctl enable btrfsmaintenance-refresh.path

# Reloads systemd manager configuration
sudo systemctl daemon-reload

# Loads and applies kernel parameter settings from the 99-zram.conf
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Clean up system
sudo nala clean && sudo nala autopurge && flatpak uninstall --unused

# Removes old Proton GE files
for file in "$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton"*; do
    [ -e "$file" ] && sudo rm -rv "$file"
done

# Runs script to install latest Proton GE
chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh"
"$HOME/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh"

# Update aliases
sed -i '/^# Updates system/,${/^# Updates system/d; d;}' "$HOME/.bashrc"
cat "$HOME/Documents/linux_docs/configs/aliases/apt_aliases.txt" >> "$HOME/.bashrc"

# Prints a conclusive message
echo "Tweaks complete"
read -p "Press enter to exit"
