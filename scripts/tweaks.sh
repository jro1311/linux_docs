#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for package manager
if ! command -v apt > /dev/null 2>&1; then
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Refreshes package repositories and installs package(s)
sudo apt-get update && sudo apt-get install -y nala

# Clean system and remove orphaned package(s)
sudo nala clean && sudo nala autoremove -y && flatpak uninstall --unused -y

# Removes package(s)
if command -v goverlay > /dev/null 2>&1; then
    sudo nala purge -y goverlay
fi

if command -v librewolf > /dev/null 2>&1; then
    sudo nala remove -y librewolf
fi

if command -v corectrl > /dev/null 2>&1; then
    sudo nala purge -y corectrl
    sudo rm -fv /etc/polkit-1/rules.d/90-corectrl.rules
    rm -v "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop"
fi

if flatpak list --columns=application | grep -Fq "com.discordapp.Discord"; then
    flatpak remove -y com.discordapp.Discord
fi

# Checks for wheel group and adds the current user to it
if getent group wheel > /dev/null 2>&1; then
    sudo usermod -aG wheel "$USER"
    echo "${green}Added $USER to wheel group ${reset}"
else
    echo "${yellow}wheel group does not exist ${reset}"
fi

# Upgrades system 
sudo nala upgrade -y && flatpak update -y && cinnamon-spice-updater --update-all

# Installs package(s)
sudo nala install -y software-properties-common

# Adds repo(s)
sudo add-apt-repository multiverse

packages=(
"btop"
"btrfs-compsize"
"btrfsmaintenance"
"cpu-x"
"curl"
"dos2unix"
"firefox"
"flatpak"
"fontconfig"
"fzf"
"git"
"gnome-clocks"
"gnome-weather"
"gsmartcontrol"
"htop"
"inxi"
"libavcodec-extra"
"libdvd-pkg"
"mangohud"
"memtest86+"
"mintchat"
"mint-meta-codecs"
"mpv"
"nano"
"neofetch"
"rocm-smi"
"shellcheck"
"smartmontools"
"steam-installer"
"systemd-zram-generator"
"tealdeer"
"transmission-gtk"
"ttf-mscorefonts-installer"
"yt-dlp"
)

auto_flatpaks=(
"com.geeks3d.furmark"
"com.github.Matoking.protontricks"
"com.github.tchx84.Flatseal"
"com.heroicgameslauncher.hgl"
"io.github.ilya_zlobintsev.LACT"
"org.libreoffice.LibreOffice"
"org.prismlauncher.PrismLauncher"
"dev.vencord.Vesktop"
)

manual_flatpaks=(
"org.freedesktop.Platform.ffmpeg-full"
"org.freedesktop.Platform.VulkanLayer.MangoHud"
)

# Installs package(s)
sudo nala install -y "${packages[@]}"
flatpak install flathub -y "${auto_flatpaks[@]}"
flatpak install flathub "${manual_flatpaks[@]}"

# Checks for directory
if [ -d "$HOME/Documents/MangoHud" ]; then
    # Removes directory(s)
    rm -rv "$HOME/Documents/MangoHud"
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"
mkdir -pv "$HOME/.config/btop"
mkdir -pv "$HOME/.config/fontconfig"
mkdir -pv "$HOME/.config/htop"
mkdir -pv "$HOME/.config/MangoHud"
mkdir -pv "$HOME/.config/mpv"
mkdir -pv "$HOME/.config/nano"
mkdir -pv "$HOME/.var/app/io.mpv.Mpv/config/mpv"
mkdir -pv "$HOME/Documents/mangohud/logs"

# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/btop.conf" "$HOME/.config/btop/"
cp -v "$HOME/Documents/linux_docs/configs/packages/fonts.conf" "$HOME/.config/fontconfig/"
cp -v "$HOME/Documents/linux_docs/configs/packages/htoprc" "$HOME/.config/htop/"
cp -v "$HOME/Documents/linux_docs/configs/packages/nanorc" "$HOME/.config/nano/"
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
flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher

# Configures system timer(s)
sudo systemctl disable btrfs-defrag.timer
sudo systemctl disable btrfs-trim.timer
sudo systemctl enable btrfs-balance.timer
sudo systemctl enable btrfs-scrub.timer
sudo systemctl enable btrfsmaintenance-refresh.path

# Reloads systemd manager configuration
sudo systemctl daemon-reload

# Makes directory(s)
sudo mkdir -pv /etc/sysctl.d

# Loads and applies kernel parameter settings
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Removes old Proton GE files
for file in "$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton"*; do
    [ -e "$file" ] && sudo rm -rv "$file"
done

# Runs script to install latest Proton GE
chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh"
"$HOME/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh"

# Replaces the number 160 with 140
sed -i 's/\b160\b/140/g' "$HOME/.config/MangoHud/MangoHud.conf"

# Deletes old bashrc settings
sed -i '/^# Updates system/,${/^# Updates system/d; d;}' "$HOME/.bashrc"

# Adds custom bashrc settings
cat "$HOME/Documents/linux_docs/configs/packages/bashrc" >> "$HOME/.bashrc"

# Prints a conclusive message
echo "${green} Tweaks complete ${reset}"
