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

# Removes package(s)
if command -v goverlay > /dev/null 2>&1; then
    sudo apt-get remove -y goverlay
fi

if command -v librewolf > /dev/null 2>&1; then
    sudo apt-get remove -y librewolf
fi

if command -v corectrl > /dev/null 2>&1; then
    sudo apt-get purge -y corectrl
    sudo rm -fv /etc/polkit-1/rules.d/90-corectrl.rules
    rm -v "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop"
fi

# Clean system and remove orphaned package(s)
sudo apt-get clean && sudo apt-get autoremove -y && flatpak uninstall --unused -y

# Checks for wheel group and adds the current user to it
if getent group wheel > /dev/null 2>&1; then
    sudo usermod -aG wheel "$USER"
    echo "${green}Added $USER to wheel group ${reset}"
else
    echo "${yellow}wheel group does not exist ${reset}"
fi

# Upgrades system 
sudo apt-get update && sudo apt-get full-upgrade -y && flatpak update -y && cinnamon-spice-updater --update-all

# Installs package(s)
sudo apt-get install -y software-properties-common

# Adds repo(s)
sudo add-apt-repository multiverse

packages=(
"bash-completion"
"btop"
"btrfs-compsize"
"btrfsmaintenance"
"cpu-x"
"curl"
"dos2unix"
"flatpak"
"fontconfig"
"fwupd"
"fzf"
"git"
"gnome-boxes"
"gnome-clocks"
"gnome-weather"
"gsmartcontrol"
"hplip"
"hplip-gui"
"htop"
"inxi"
"libavcodec-extra"
"libdvd-pkg"
"mangohud"
"memtest86+"
"mintchat"
"mint-meta-codecs"
"micro"
"mpv"
"nala"
"nano"
"neofetch"
"ntfs-3g"
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
"com.discordapp.Discord"
"com.geeks3d.furmark"
"com.github.Matoking.protontricks"
"com.github.tchx84.Flatseal"
"com.heroicgameslauncher.hgl"
"com.vysp3r.ProtonPlus"
"io.github.ilya_zlobintsev.LACT"
"io.github.mhogomchungu.media-downloader"
"org.libreoffice.LibreOffice"
"org.mozilla.firefox"
"org.prismlauncher.PrismLauncher"
)

manual_flatpaks=(
"org.freedesktop.Platform.ffmpeg-full"
"org.freedesktop.Platform.VulkanLayer.MangoHud"
)

# Installs package(s)
sudo apt-get install -y "${packages[@]}"
flatpak install flathub -y "${auto_flatpaks[@]}"
flatpak install flathub "${manual_flatpaks[@]}"

# Updates firmware
fwupdmgr refresh && fwupdmgr update

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
mkdir -pv "$HOME/.config/micro"
mkdir -pv "$HOME/.config/mpv"
mkdir -pv "$HOME/.config/nano"
mkdir -pv "$HOME/.var/app/io.mpv.Mpv/config/mpv"
mkdir -pv "$HOME/Documents/mangohud/logs"
sudo mkdir -pv /etc/sysctl.d

# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/btop.conf" "$HOME/.config/btop/"
cp -v "$HOME/Documents/linux_docs/configs/packages/fonts.conf" "$HOME/.config/fontconfig/"
cp -v "$HOME/Documents/linux_docs/configs/packages/htoprc" "$HOME/.config/htop/"
cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud.conf" "$HOME/.config/MangoHud/"
cp -v "$HOME/Documents/linux_docs/configs/packages/micro/settings.json" "$HOME/.config/micro/"
cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.config/"
cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"
cp -v "$HOME/Documents/linux_docs/configs/packages/nanorc" "$HOME/.config/nano/"
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/nanorc" /etc/nanorc
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/99-zram.conf" /etc/sysctl.d/
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram-generator.conf" /etc/systemd/

# Replaces the number 160 with 140 in MangoHud config
sed -i 's/\b160\b/140/g' "$HOME/.config/MangoHud/MangoHud.conf"

# Adds output folder for MangoHud logs
echo "output_folder=$HOME/Documents/mangohud/logs" >> "$HOME/.config/MangoHud/MangoHud.conf"

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

# Makes directory(s)
mkdir -pv "$HOME/.local/share/gnome-boxes/images"
mkdir -pv "$HOME/.var/app/org.gnome.Boxes/data/gnome-boxes/images"
sudo mkdir -pv /var/lib/libvirt/images
sudo mkdir -pv /var/lib/machines
sudo mkdir -pv /var/log/journal
        
# Disables COW on specific directory(s)
chattr -R +C "$HOME/.local/share/gnome-boxes/images"
chattr -R +C "$HOME/.var/app/org.gnome.Boxes/data/gnome-boxes/images"
sudo chattr -R +C /var/lib/libvirt/images
sudo chattr -R +C /var/lib/machines
sudo chattr -R +C /var/log/journal

# Removes old Proton GE files
for file in "$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton"*; do
    [ -e "$file" ] && sudo rm -rv "$file"
done

# Checks for package and copies config(s)
if command -v nmcli > /dev/null 2>&1; then
    echo "${green}Detected: Network Manager ${reset}"

    sudo mkdir -pv /etc/NetworkManager/conf.d

    if ! grep -Fq "wifi.cloned-mac-address=permanent" /etc/NetworkManager/NetworkManager.conf; then
        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/10-permanent-mac-address.conf" /etc/NetworkManager/conf.d/

        if command -v systemctl > /dev/null 2>&1; then
            sudo systemctl restart NetworkManager
        fi

    else
        echo "${green}Permanent MAC address is already enabled ${reset}"
    fi

else
    echo "${yellow}Network Manager not detected ${reset}"
fi

# Adds full preemption to kernel arguments
if ! grep -Fq "preempt=full" /etc/default/grub; then

    sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 preempt=full"/' /etc/default/grub
    echo "${green}Added preempt=full to kernel arguments ${reset}"

else
    echo "${green}preempt=full already part of kernel arguments ${reset}"
fi

# Adds full AMD GPU control to kernel arguments
if ! grep -Fq "amdgpu.ppfeaturemask=0xffffffff" /etc/default/grub; then

    sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 amdgpu.ppfeaturemask=0xffffffff"/' /etc/default/grub
    echo "${green}Added amdgpu.ppfeaturemask=0xffffffff to kernel arguments  ${reset}"

else
    echo "${green}amdgpu.ppfeaturemask=0xffffffff already part of kernel arguments ${reset}"
fi


# Updates GRUB configuration
sudo update-grub

# Reloads systemd manager configuration
sudo systemctl daemon-reload

# Loads and applies kernel parameter settings
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Deletes old bashrc settings
sed -i '/^# Updates system/,${/^# Updates system/d; d;}' "$HOME/.bashrc"

# Adds custom bashrc settings
cat "$HOME/Documents/linux_docs/configs/packages/bashrc" >> "$HOME/.bashrc"

# Prints a conclusive message
echo "${green}Tweaks complete ${reset}"
