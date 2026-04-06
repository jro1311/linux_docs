#!/usr/bin/env bash
# shellcheck disable=SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc
shopt -u globstar nullglob

detect_system

if [ "$primary_pm" != "apt" ]; then
    unsupported_package_manager
    exit 1
fi

# Prints system information
if [ "$os_like" != "$os" ]; then
    print_field  "Base Distro(s)" "$os_like"
fi

print_field "Distro" "$os"
print_field "Version" "$VERSION_ID"
print_field "Primary Package Manager" "$primary_pm"
print_field "Secondary Package Manager" "$secondary_pm"

alternatives=(
    "flatpak"
    "snap"
    "toolbox"
)

for alt in "${alternatives[@]}"; do
    var="${alt}_installed"
    if [ -v "$var" ]; then
        if [ "${!var}" -eq 1 ]; then
            print_field "Detected" "$alt"
        fi
    fi
done

print_field "Desktop" "$desktop"
print_field "Init System" "$init_system"
print_field "Root File System" "$root_filesystem"
print_field "Home File System" "$home_filesystem"
print_field "Network Interface" "$network_interface"

if [ "$battery_detected" -eq 1 ]; then
    print_field "Detected" "Battery"
fi

read -r -p "Press enter to proceed, or ctrl+c to cancel: "

if getent group wheel >/dev/null 2>&1; then
    sudo usermod -aG wheel "$USER"
    green_message "'$USER' added to 'wheel' group."
fi

cow_dirs=(
    "$HOME/.local/share/flatpak"
    /var/lib/flatpak
)

nocow_dirs=(
    "$HOME/.local/share/gnome-boxes/images"
    "$HOME/.var/app/org.gnome.Boxes/data/gnome-boxes/images"
    /var/lib/libvirt/images
    /var/lib/machines
    /var/log/journal
)

# Enables COW on specific directory(s)
for cow_dir in "${cow_dirs[@]}"; do
    sudo_run_passthrough mkdir -pv "${cow_dir[@]}" && sudo_run chattr -C "${cow_dir[@]}"
done

# Disables COW on specific directory(s)
for nocow_dir in "${nocow_dirs[@]}"; do
    sudo_run_passthrough mkdir -pv "${nocow_dir[@]}" && sudo_run chattr +C "${nocow_dir[@]}"
done

check goverlay && {
    sudo apt-get purge -y goverlay
}

sudo apt-get autoremove -y && sudo  apt-get clean && flatpak uninstall --unused -y

# Enables 32-bit libraries
sudo dpkg --add-architecture i386

sudo apt-get update && sudo apt-get full-upgrade -y && flatpak update -y
sudo apt-get install -y software-properties-common
sudo add-apt-repository multiverse && sudo  apt-get update

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
    "mint-meta-codecs"
    "micro"
    "mpv"
    "nala"
    "nano"
    "neofetch"
    "ntfs-3g"
    "perl"
    "rocm-smi"
    "rsync"
    "shellcheck"
    "smartmontools"
    "steam-installer"
    "systemd-zram-generator"
    "tealdeer"
    "transmission-gtk"
    "ttf-mscorefonts-installer"
    "yt-dlp"
)

flatpaks=(
    "com.discordapp.Discord"
    "com.geeks3d.furmark"
    "com.github.Matoking.protontricks"
    "com.github.tchx84.Flatseal"
    "com.heroicgameslauncher.hgl"
    "com.vysp3r.ProtonPlus"
    "io.github.mhogomchungu.media-downloader"
    "org.libreoffice.LibreOffice"
    "org.freedesktop.Platform.codecs-extra"
    "org.freedesktop.Platform.ffmpeg-full"
    "org.freedesktop.Platform.VulkanLayer.MangoHud"
    "org.prismlauncher.PrismLauncher"
)

sudo apt-get install -y "${packages[@]}"

if [ "$flatpak_installed" -eq 1 ]; then
    flatpak install flathub -y "${flatpaks[@]}"

    # Undo giving all flatpaks read-only permission to MangoHud's config file
    flatpak override --user --reset=xdg-config/MangoHud

    # Undo forcing Flatseal to use Adwaita Dark theme
    flatpak override --user --reset=GTK_THEME com.github.tchx84.Flatseal

    # Grants only certain flatpaks read-only access to MangoHud's config
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
    flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher
fi

if [ -d "$HOME/Documents/MangoHud" ]; then
    rm -rfv "$HOME/Documents/MangoHud"
fi

# Removes old Proton GE files
for file in "$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton"*; do
    [ -e "$file" ] && sudo rm -rv "$file"
done

# Removes old bashrc settings
sed -i '/^# Updates system/,${/^# Updates system/d; d;}' "$HOME/.bashrc"

sudo systemctl disable btrfs-defrag.timer
sudo systemctl disable btrfs-trim.timer
sudo systemctl enable btrfs-balance.timer
sudo systemctl enable btrfs-scrub.timer
sudo systemctl enable btrfsmaintenance-refresh.path

# Makes directory(s) in a loop
config_dirs=(
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
    /etc/sysctl.d/
)

for config_dir in "${config_dirs[@]}"; do
    sudo_run_passthrough mkdir -pv "$config_dir"
done

enable_permanent_mac_address

# Copies config(s) using a two array element pair loop
configs=(
    "$HOME/Documents/linux_docs/configs/applications/btop.conf" "$HOME/.config/btop/"
    "$HOME/Documents/linux_docs/configs/applications/htoprc" "$HOME/.config/htop/"
    "$HOME/Documents/linux_docs/configs/applications/MangoHud.conf" "$HOME/.config/MangoHud/"
    "$HOME/Documents/linux_docs/configs/applications/micro/settings.json" "$HOME/.config/micro/"
    "$HOME/Documents/linux_docs/configs/applications/mpv" "$HOME/.config/"
    "$HOME/Documents/linux_docs/configs/applications/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"
    "$HOME/Documents/linux_docs/configs/applications/nanorc" "$HOME/.config/nano/"
    "$HOME/Documents/linux_docs/configs/system/fontconfig/fonts.conf" "$HOME/.config/fontconfig/"
    "$HOME/Documents/linux_docs/configs/applications/nanorc" /etc/nanorc
    "$HOME/Documents/linux_docs/configs/system/zram/zram-generator.conf" /etc/systemd/
    "$HOME/Documents/linux_docs/configs/system/zram/99-zram.conf" /etc/sysctl.d/
)

for ((i=0; i<${#configs[@]}; i+=2)); do
    sudo_run_passthrough cp -rv "${configs[i]}" "${configs[i+1]}"
done

install_mangohud

# Set micro and nano to use tabs instead of spaces
sed -i 's/"tabstospaces": true/"tabstospaces": false/' "$HOME/.config/micro/settings.json"
sed -i 's/set tabstospaces/#set tabstospaces/' "$HOME/.config/nano/nanorc"
sudo sed -i 's/set tabstospaces/#set tabstospaces/' /etc/nanorc

remove_kernel_parameter \
    "preempt=full" \
    "amdgpu.ppfeaturemask=0xffffffff"
add_kernel_parameter \
    "preempt=full"
    "amdgpu.ppfeaturemask=0xffffffff"

sudo systemctl daemon-reload
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Installs Deno (JavaScript runtime)
curl -fsSL https://deno.land/install.sh | sh

chmod +x "$HOME/Documents/linux_docs/scripts/sync_bashrc_configs.sh"
"$HOME/Documents/linux_docs/scripts/sync_bashrc_configs.sh"

# Updates firmware
fwupdmgr refresh && fwupdmgr update

green_message "Success:" "Tweaks complete. Reboot to apply all changes."
