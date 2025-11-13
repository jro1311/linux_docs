#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Checks for package manager
if ! command -v apt > /dev/null 2>&1; then
    echo "${red}Unsupported package manager. ${reset}"
    exit 1
fi

# Makes directory(s)
mkdir -pv "$HOME/.local/share/flatpak"
mkdir -pv "$HOME/.local/share/gnome-boxes/images"
mkdir -pv "$HOME/.var/app/org.gnome.Boxes/data/gnome-boxes/images"
sudo mkdir -pv /var/lib/flatpak
sudo mkdir -pv /var/lib/libvirt/images
sudo mkdir -pv /var/lib/machines
sudo mkdir -pv /var/log/journal

# Enables COW on specific directory(s)
chattr -C "$HOME/.local/share/flatpak"
sudo chattr -C /var/lib/flatpak

# Disables COW on specific directory(s)
chattr +C "$HOME/.local/share/gnome-boxes/images"
chattr +C "$HOME/.var/app/org.gnome.Boxes/data/gnome-boxes/images"
sudo chattr +C /var/lib/libvirt/images
sudo chattr +C /var/lib/machines
sudo chattr +C /var/log/journal

# Check for package or package manager
check() {
    local cmd="$1"
    shift
    if command -v "$cmd" > /dev/null 2>&1; then
        "$@"
    fi
}

# Removes package(s)
check goverlay && sudo apt-get remove -y goverlay
check librewolf && sudo apt-get remove -y librewolf
check corectrl && sudo apt-get purge -y corectrl
sudo apt-get autoremove -y && sudo apt-get clean && flatpak uninstall --unused -y

# Removes config(s)
if [ -f /etc/polkit-1/rules.d/90-corectrl.rules ]; then
    sudo rm -fv /etc/polkit-1/rules.d/90-corectrl.rules
fi

if [ -f "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop" ]; then
    rm -fv "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop"
fi

# Checks for wheel group and adds the current user to it
if getent group wheel > /dev/null 2>&1; then

    sudo usermod -aG wheel "$USER"
    echo "${green}'$USER' added to 'wheel' group. ${reset}"

fi

# Enables 32-bit libraries
sudo dpkg --add-architecture i386

sudo apt-get update && sudo apt-get full-upgrade -y && flatpak update -y
sudo apt-get install -y software-properties-common
sudo add-apt-repository multiverse

packages=(
"bash-completion"
"btop"
"btrfs-compsize"
"btrfsmaintenance"
"cpu-x"
"curl"
"dos2unix"
"firefox"
"flatpak"
"fontconfig"
"fwupd"
"gawk"
"git"
"gnome-boxes"
"gnome-clocks"
"gnome-weather"
"gsmartcontrol"
"hplip"
"hplip-gui"
"htop"
"inxi"
"jq"
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
"perl"
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
"org.prismlauncher.PrismLauncher"
)

manual_flatpaks=(
"org.freedesktop.Platform.ffmpeg-full"
"org.freedesktop.Platform.VulkanLayer.MangoHud"
)

sudo apt-get install -y "${packages[@]}"
flatpak install flathub -y "${auto_flatpaks[@]}"
flatpak install flathub "${manual_flatpaks[@]}"

# Checks for directory
if [ -d "$HOME/Documents/MangoHud" ]; then

    # Removes directory(s)
    rm -rfv "$HOME/Documents/MangoHud"

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
cp -v "$HOME/Documents/linux_docs/configs/packages/fontconfig/fonts.conf" "$HOME/.config/fontconfig/"
cp -v "$HOME/Documents/linux_docs/configs/packages/htoprc" "$HOME/.config/htop/"
cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud.conf" "$HOME/.config/MangoHud/"
cp -v "$HOME/Documents/linux_docs/configs/packages/micro/settings.json" "$HOME/.config/micro/"
cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.config/"
cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"
cp -v "$HOME/Documents/linux_docs/configs/packages/nanorc" "$HOME/.config/nano/"
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/nanorc" /etc/nanorc
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram/99-zram.conf" /etc/sysctl.d/
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram/zram-generator.conf" /etc/systemd/

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

# Removes old Proton GE files
for file in "$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton"*; do
    [ -e "$file" ] && sudo rm -rv "$file"
done

# Checks for package and copies config(s)
if command -v nmcli > /dev/null 2>&1; then
    echo "${green}Detected: Network Manager ${reset}"

    if [ ! -f /etc/NetworkManager/conf.d/10-permanent-mac-address.conf ]; then

        sudo mkdir -pv /etc/NetworkManager/conf.d
        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/network_manager/10-permanent-mac-address.conf" /etc/NetworkManager/conf.d/

        if command -v systemctl > /dev/null 2>&1; then
            sudo systemctl restart NetworkManager
        fi

    else
        echo "${green}Permanent MAC address is already enabled. ${reset}"
    fi

else
    echo "${yellow}Network Manager not detected. ${reset}"
fi

# Kernel arguments
karg1="preempt=full"
karg2="amdgpu.ppfeaturemask=0xffffffff"

# Adds full preemption to kernel arguments
if ! grep -Fq "$karg1" /etc/default/grub; then

    sudo sed -i "s/\(GRUB_CMDLINE_LINUX=\"[^\"]*\)\"/\1 $karg1\"/" /etc/default/grub
    echo "${green}'$karg1' added to kernel arguments. ${reset}"

else
    echo "${green}'$karg1' already part of kernel arguments. ${reset}"
fi

# Adds full AMD GPU control to kernel arguments
if ! grep -Fq "$karg2" /etc/default/grub; then

    sudo sed -i "s/\(GRUB_CMDLINE_LINUX=\"[^\"]*\)\"/\1 $karg2\"/" /etc/default/grub
    echo "${green}'$karg2' added to kernel arguments. ${reset}"

else
    echo "${green}'$karg2' already part of kernel arguments. ${reset}"
fi

# Updates GRUB configuration
sudo update-grub

# Reloads systemd manager configuration
sudo systemctl daemon-reload

# Loads and applies kernel parameter settings
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Updates bashrc
sed -i '/^# Updates system/,${/^# Updates system/d; d;}' "$HOME/.bashrc"
cat "$HOME/Documents/linux_docs/configs/packages/bashrc" >> "$HOME/.bashrc"

# Updates firmware
fwupdmgr refresh && fwupdmgr update

# Prints a conclusive message
echo "${green}Tweaks complete. ${reset}"
