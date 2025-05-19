#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Makes directory(s)
mkdir -pv $HOME/.config/btop
mkdir -pv $HOME/Documents/MangoHud/logs
    
# Copies config(s)
cp -v $HOME/Documents/linux_docs/configs/packages/nanorc $HOME/.config/
cp -v $HOME/Documents/linux_docs/configs/packages/btop.conf $HOME/.config/btop/
    
# Changes name(s)
mv -v $HOME/.config/nanorc $HOME/.config/.nanorc

# Removes CoreCtrl from the system
sudo nala purge -y corectrl
sudo rm -fv /etc/polkit-1/rules.d/90-corectrl.rules
rm -v $HOME/.config/autostart/org.corectrl.CoreCtrl.desktop

# Updates system 
sudo nala upgrade && flatpak update && cinnamon-spice-updater --update-all

# Installs package(s)
sudo nala install -y btop cpu-x curl firefox flatpak fzf gsmartcontrol htop memtest86+ mintchat mint-meta-codecs mpv neofetch rocm-smi smartmontools systemd-zram-generator tealdeer transmission-gtk ttf-mscorefonts-installer yt-dlp

# Installs package(s)
flatpak install flathub -y discordapp runtime/org.freedesktop.Platform.ffmpeg-full/x86_64/24.08 flatseal runtime/org.freedesktop.Platform.GStreamer.gstreamer-vaapi/x86_64/23.08 app/org.libreoffice.LibreOffice/x86_64/stable

# Uninstalls package(s)
sudo nala remove -y goverlay

# Installs package(s)
sudo nala install -y mangohud steam-installer
flatpak install flathub -y furmark lact runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08 mangojuice prismlauncher com.github.Matoking.protontricks/x86_64/stable

# Enables LACT
sudo systemctl enable --now lactd

# Undo giving all flatpaks read-only permission to MangoHud's config file
flatpak override --user --reset=xdg-config/MangoHud

# Undo forcing Flatseal to use Adwaita Dark theme
flatpak override --user --reset=GTK_THEME com.github.tchx84.Flatseal

# Grants only certain flatpaks read-only access to MangoHud's config
flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark 
flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher

# Clean up system
sudo nala clean && sudo nala autopurge && flatpak uninstall --unused

# Runs script to install latest Proton GE
chmod +x $HOME/Documents/linux_docs/scripts/packages/proton_ge_install.sh
$HOME/Documents/linux_docs/scripts/packages/proton_ge_install.sh

# Update aliases
sed -i '/^# Updates system/,${/^# Updates system/d; d;}' $HOME/.bashrc
cat $HOME/Documents/linux_docs/configs/aliases/aliases_linux_mint.md >> $HOME/.bashrc

# Prints a conclusive message to end the script
echo "Tweaks have been succesfully made to the system."
