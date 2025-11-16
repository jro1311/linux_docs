#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Define terminal text colors using tput
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

red_message() {
    local message="$1"
    echo "${red}$message ${reset}"
}

green_message() {
    local message="$1"
    echo "${green}$message ${reset}"
}

yellow_message() {
    local message="$1"
    echo "${yellow}$message ${reset}"
}

check() {
    local cmd="$1"
    shift
    if command -v "$cmd" >/dev/null 2>&1; then
        "$@"
    fi
}

inverse_check() {
    local cmd="$1"
    shift
    if ! command -v "$cmd" >/dev/null 2>&1; then
        "$@"
    fi
}

# Define package managers
primary_package_manager="unknown"
secondary_package_manager="unknown"

primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)
secondary_package_managers=(nala paru yay)

for cmd in "${primary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        primary_package_manager="$cmd"
        break
    fi
done

for cmd in "${secondary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        secondary_package_manager="$cmd"
        break
    fi
done

# Normalizes xbps-install to xbps
if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    echo "${green}Primary Package Manager: $primary_package_manager ${reset}"
fi

if [ "$secondary_package_manager" != "unknown" ]; then
    echo "${green}Secondary Package Manager: $secondary_package_manager ${reset}"
fi

# Define bootloader
bootloader="unknown"
update_bootloader="unknown"

if command -v update-grub >/dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="update-grub"

elif command -v grub2-mkconfig >/dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub2-mkconfig -o /boot/grub2/grub.cfg"

elif command -v grub-mkconfig >/dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub-mkconfig -o /boot/grub/grub.cfg"

elif command -v limine-update >/dev/null 2>&1; then
    bootloader="limine"
    update_bootloader="limine-update"

elif find /boot/efi/EFI -name "*systemd-boot*.efi" >/dev/null 2>&1; then
    bootloader="systemd-boot"
    update_bootloader="bootctl update"
fi

if [ "$bootloader" != "unknown" ]; then
    echo "${green}Bootloader: $bootloader ${reset}"
fi

add_kernel_argument() {
    local karg="$1"
    case "$primary_package_manager" in
        "rpm-ostree")
            if ! rpm-ostree kargs | grep -Fq "$karg"; then
                sudo rpm-ostree kargs --append="$karg"
                green_message "'$karg' added to kernel arguments."
            else
                green_message "'$karg' already part of kernel arguments."
            fi
            ;;
        *)
            case "$bootloader" in
                "grub")
                    if ! grep -Fq "$karg" /etc/default/grub; then
                        sudo sed -i "s/\(GRUB_CMDLINE_LINUX=\"[^\"]*\)\"/\1 $karg\"/" /etc/default/grub
                        green_message "'$karg' added to kernel arguments."
                        sudo bash -c "$update_bootloader"
                    else
                        green_message "'$karg' already part of kernel arguments."
                    fi
                    ;;
                "limine")
                    if ! grep -Fq "$karg" /etc/default/limine; then
                        sudo sed -i "/^KERNEL_CMDLINE\[default\\]/ s/\"$/ $karg\"/" /etc/default/limine
                        green_message "'$karg' added to kernel arguments."
                        sudo bash -c "$update_bootloader"
                    else
                        green_message "'$karg' already part of kernel arguments."
                    fi
                    ;;
                *)
                    unsupported_bootloader
                    return 1
            esac
            ;;
    esac
}

enable_permanent_mac_address() {
    if command -v nmcli >/dev/null 2>&1; then
        green_message "Detected: Network Manager"

        if [ ! -f /etc/NetworkManager/conf.d/10-permanent-mac-address.conf ]; then
            sudo mkdir -pv /etc/NetworkManager/conf.d
            sudo cp -v "$HOME/Documents/linux_docs/configs/system/network_manager/10-permanent-mac-address.conf" /etc/NetworkManager/conf.d/

            if command -v systemctl >/dev/null 2>&1; then
                sudo systemctl restart NetworkManager
            fi
        else
            green_message "Permanent MAC address already enabled."
            return 0
        fi
    else
        yellow_message "Network Manager not detected."
    fi

    green_message "Enabled: Permanent MAC address"
}

sync_bashrc_configs() {
    mkdir -pv "$HOME/.bashrc.d"

    # shellcheck disable=SC2016
    if ! grep -Fq '# Sources all .sh files in $HOME/.bashrc.d' "$HOME/.bashrc"; then
        cat "$HOME/Documents/linux_docs/configs/system/bash/bashrc" >> "$HOME/.bashrc"
        echo "${green}Enabled recursive sourcing in $HOME/.bashrc.d ${reset}"
    fi

    # Define source and destination directory
    source="$HOME/Documents/linux_docs/configs/system/bash/bashrc.d/"
    destination="$HOME/.bashrc.d/"

    # Syncs the source with the destination and checks if it was successful
    if rsync -auhvP --delete "$source" "$destination"; then
        echo "${green}Success: '$source' synced with '$destination' ${reset}"
    else
        echo "${red}Error: '$source' failed to sync with '$destination' ${reset}"
        return 1
    fi
}

if [ "$primary_package_manager" != "apt" ]; then
    echo "${red}Unsupported package manager. ${reset}"
    exit 1
fi

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

check librewolf sudo apt-get remove -y librewolf
check goverlay sudo apt-get purge -y goverlay
# check corectrl sudo apt-get purge -y corectrl

# if [ -f /etc/polkit-1/rules.d/90-corectrl.rules ]; then
#     sudo rm -fv /etc/polkit-1/rules.d/90-corectrl.rules
# fi
#
# if [ -f "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop" ]; then
#     rm -fv "$HOME/.config/autostart/org.corectrl.CoreCtrl.desktop"
# fi

sudo apt-get autoremove -y && sudo apt-get clean && flatpak uninstall --unused -y

# Checks for wheel group and adds the current user to it
if getent group wheel >/dev/null 2>&1; then
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
# "io.github.ilya_zlobintsev.LACT"
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

if [ -d "$HOME/Documents/MangoHud" ]; then
    rm -rfv "$HOME/Documents/MangoHud"
fi

# Removes old Proton GE files
for file in "$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton"*; do
    [ -e "$file" ] && sudo rm -rv "$file"
done

# Removes old bashrc settings
sed -i '/^# Updates system/,${/^# Updates system/d; d;}' "$HOME/.bashrc"

# sudo systemctl enable --now lactd

# Undo giving all flatpaks read-only permission to MangoHud's config file
flatpak override --user --reset=xdg-config/MangoHud

# Undo forcing Flatseal to use Adwaita Dark theme
flatpak override --user --reset=GTK_THEME com.github.tchx84.Flatseal

# Grants only certain flatpaks read-only access to MangoHud's config
flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark
flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher

# Configures systemd timers and paths
sudo systemctl disable btrfs-defrag.timer
sudo systemctl disable btrfs-trim.timer
sudo systemctl enable btrfs-balance.timer
sudo systemctl enable btrfs-scrub.timer
sudo systemctl enable btrfsmaintenance-refresh.path

# Makes directory(s) in a loop
home_dirs=(
    "$HOME/.config/autostart"
    "$HOME/.config/btop"
    "$HOME/.config/fontconfig"
    "$HOME/.config/htop"
    "$HOME/.config/MangoHud"
    "$HOME/.config/micro"
    "$HOME/.config/mpv"
    "$HOME/.config/nano"
    "$HOME/.var/app/io.mpv.Mpv/config/mpv"
    "$HOME/Documents/mangohud/logs"
)

for dir in "${home_dirs[@]}"; do
    mkdir -pv "$dir"
done

sys_dirs=(
    /etc/nanorc
    /etc/sysctl.d/
)

for dir in "${sys_dirs[@]}"; do
    sudo mkdir -pv "$dir"
done

enable_permanent_mac_address
sync_bashrc_configs

# Copies config(s) using a two array element pair loop
home_configs=(
    "$HOME/Documents/linux_docs/configs/applications/btop.conf" "$HOME/.config/btop/"
    "$HOME/Documents/linux_docs/configs/applications/htoprc" "$HOME/.config/htop/"
    "$HOME/Documents/linux_docs/configs/applications/MangoHud.conf" "$HOME/.config/MangoHud/"
    "$HOME/Documents/linux_docs/configs/applications/micro/settings.json" "$HOME/.config/micro/"
    "$HOME/Documents/linux_docs/configs/applications/mpv" "$HOME/.config/"
    "$HOME/Documents/linux_docs/configs/applications/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"
    "$HOME/Documents/linux_docs/configs/applications/nanorc" "$HOME/.config/nano/"
    "$HOME/Documents/linux_docs/configs/system/fontconfig/fonts.conf" "$HOME/.config/fontconfig/"
)

for ((i=0; i<${#home_configs[@]}; i+=2)); do
    cp -rv "${home_configs[i]}" "${home_configs[i+1]}"
done

sys_configs=(
    "$HOME/Documents/linux_docs/configs/applications/nanorc" /etc/nanorc
    "$HOME/Documents/linux_docs/configs/system/zram/99-zram.conf" /etc/sysctl.d/
)

for ((i=0; i<${#sys_configs[@]}; i+=2)); do
    sudo cp -rv "${sys_configs[i]}" "${sys_configs[i+1]}"
done

# Changes max FPS limit to 140 in MangoHud config
sed -i 's/\b160\b/140/g' "$HOME/.config/MangoHud/MangoHud.conf"

# Adds output folder for MangoHud logs
echo "output_folder=$HOME/Documents/mangohud/logs" >> "$HOME/.config/MangoHud/MangoHud.conf"

add_kernel_argument "preempt=full"
add_kernel_argument "amdgpu.ppfeaturemask=0xffffffff"

# Reloads systemd manager configuration
sudo systemctl daemon-reload

# Reads and applies kernel parameter settings
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Updates firmware
fwupdmgr refresh && fwupdmgr update

echo "${green}Tweaks complete. ${reset}"
