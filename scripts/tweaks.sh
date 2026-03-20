#!/usr/bin/env bash

# Exit on error, unset var, or pipe failure
set -euo pipefail

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f $rc ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob
shopt -s nullglob

# Detect host system
host_system="unknown"
batteries=(/sys/class/power_supply/BAT*)

if (( ${#batteries[@]} )); then
    host_system="laptop"
else
    host_system="desktop"
fi

if [ "$host_system" != "unknown" ]; then
    green_message "Host System: $host_system"
fi

shopt -u nullglob

# Define the operating system and convert it to lowercase
if [ -f /etc/os-release ]; then
    source /etc/os-release

    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"

    os="${os,,}"
    os_like="${os_like,,}"

    debian_version="0"
    ubuntu_version="0"
    linuxmint_version="0"
    fedora_version="0"
    openmandriva_version="0"
    opensuse_version="0"

    if [ "$os_like" != "$os" ]; then
        green_message "Base Distro(s): $os_like"
    fi

    green_message "Distro: $os"

    case "$os" in
        "debian")
            debian_version="${VERSION_ID:-0}"
            green_message "Distro Version: $debian_version"
            ;;
        "ubuntu")
            ubuntu_version="${VERSION_ID:-0}"
            green_message "Distro Version: $ubuntu_version"
            ;;
        "linuxmint")
            linuxmint_version="${VERSION_ID:-0}"
            green_message "Distro Version: $linuxmint_version"
            ;;
        "fedora")
            fedora_version="${VERSION_ID:-0}"
            green_message "Distro Version: $fedora_version"
            ;;
        "openmandriva")
            openmandriva_version="${VERSION_ID:-0}"
            green_message "Distro Version: $openmandriva_version"
            ;;
        "opensuse-leap")
            opensuse_version="${VERSION_ID:-0}"
            green_message "Distro Version: $opensuse_version"
            ;;
        *)
            case "$os_like" in
                "debian")
                    debian_version="${VERSION_ID:-0}"
                    green_message "Base Version: $debian_version"
                    ;;
                "ubuntu debian")
                    ubuntu_version="${VERSION_ID:-0}"
                    green_message "Base Version: $ubuntu_version"
                    ;;
                "fedora")
                    fedora_version="${VERSION_ID:-0}"
                    green_message "Base Version: $fedora_version"
                    ;;
            esac
            ;;
    esac
fi

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

# Normalize xbps-install to xbps
if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

if [ "$primary_package_manager" != "unknown" ]; then
    green_message "Primary Package Manager: $primary_package_manager"
fi

if [ "$secondary_package_manager" != "unknown" ]; then
    green_message "Secondary Package Manager: $secondary_package_manager"
fi

# Define the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')
green_message "Desktop: $desktop"

# Define init system
init_system="unknown"
pid1_comm=$(ps -p 1 -o comm=)

case "$pid1_comm" in
    "systemd"|"dinit"|"runit")
        init_system="$pid1_comm"
        ;;
    "openrc"|"openrc-init"|"rc")
        init_system="openrc"
        ;;
    "s6-linux-init")
        init_system="s6"
        ;;
    "init")
        init_system="sysvinit"
        ;;
esac

if [ "$init_system" != "unknown" ]; then
    green_message "Init System: $init_system"
fi

# Define file system of root directory
root_filesystem="$(df -T / | awk 'NR==2 {print $2}')"
green_message "Root File System: $root_filesystem"

# Define file system of home directory
home_filesystem="$(df -T /home | awk 'NR==2 {print $2}')"
green_message "Home File System: $home_filesystem"

sync_bashrc_configs() {
    mkdir -pv "$HOME/.bashrc.d"

    # shellcheck disable=SC2016
    if ! grep -Fq '# Sources all .sh files in $HOME/.bashrc.d' "$HOME/.bashrc"; then
        cat "$HOME/Documents/linux_docs/configs/system/bash/bashrc" >> "$HOME/.bashrc"
        green_message "Enabled recursive sourcing in $HOME/.bashrc.d"
    fi

    # Define source and destination directory
    source_dir="$HOME/Documents/linux_docs/configs/system/bash/bashrc.d/"
    destination_dir="$HOME/.bashrc.d/"

    # Syncs the source with the destination and checks if it was successful
    if rsync -auhvP --delete "$source_dir" "$destination_dir"; then
        green_message "Success: '$source_dir' synced with '$destination_dir'"
    else
        red_message "Error: '$source_dir' failed to sync with '$destination_dir'"
        return 1
    fi
}

if [ "$primary_package_manager" != "apt" ]; then
    unsupported_package_manager
    exit 1
fi

read -r -p "Press enter to proceed, or ctrl+c to cancel: "

# Checks for wheel group and adds the current user to it
if getent group wheel >/dev/null 2>&1; then
    sudo usermod -aG wheel "$USER"
    green_message "'$USER' added to 'wheel' group."
fi

mkdir -pv "$HOME/.local/share/flatpak"
mkdir -pv "$HOME/.local/share/gnome-boxes/images"
mkdir -pv "$HOME/.var/app/org.gnome.Boxes/data/gnome-boxes/images"
sudo mkdir -pv /var/lib/flatpak
sudo mkdir -pv /var/lib/libvirt/images
sudo mkdir -pv /var/lib/machines
sudo mkdir -pv /var/log/journal

# Enables COW on specific directory(s)
sudo_run chattr -C "$HOME/.local/share/flatpak"
sudo_run chattr -C /var/lib/flatpak

# Disables COW on specific directory(s)
sudo_run chattr +C "$HOME/.local/share/gnome-boxes/images"
sudo_run chattr +C "$HOME/.var/app/org.gnome.Boxes/data/gnome-boxes/images"
sudo_run chattr +C /var/lib/libvirt/images
sudo_run chattr +C /var/lib/machines
sudo_run chattr +C /var/log/journal

check goverlay sudo apt-get purge -y goverlay
sudo apt-get autoremove -y && sudo apt-get clean && flatpak uninstall --unused -y

# Enables 32-bit libraries
sudo dpkg --add-architecture i386

sudo apt-get update && sudo apt-get full-upgrade -y && flatpak update -y
sudo apt-get install -y software-properties-common
sudo add-apt-repository multiverse && sudo apt-get update

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
flatpak install flathub -y "${flatpaks[@]}"

# Installs Deno (JavaScript runtime)
curl -fsSL https://deno.land/install.sh | sh

if [ -d "$HOME/Documents/MangoHud" ]; then
    rm -rfv "$HOME/Documents/MangoHud"
fi

# Removes old Proton GE files
for file in "$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton"*; do
    [ -e "$file" ] && sudo rm -rv "$file"
done

# Removes old bashrc settings
sed -i '/^# Updates system/,${/^# Updates system/d; d;}' "$HOME/.bashrc"

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
"$HOME/Documents/linux_docs/configs/system/zram/zram-generator.conf" /etc/systemd/
"$HOME/Documents/linux_docs/configs/system/zram/99-zram.conf" /etc/sysctl.d/
)

for ((i=0; i<${#sys_configs[@]}; i+=2)); do
    sudo cp -rv "${sys_configs[i]}" "${sys_configs[i+1]}"
done

# Changes max FPS limit to 140 in MangoHud config
sed -i 's/\b160\b/140/g' "$HOME/.config/MangoHud/MangoHud.conf"

# Adds output folder for MangoHud logs
echo "output_folder=$HOME/Documents/mangohud/logs" >> "$HOME/.config/MangoHud/MangoHud.conf"

remove_kernel_parameter "preempt=full"
remove_kernel_parameter "amdgpu.ppfeaturemask=0xffffffff"
add_kernel_parameter "preempt=full"
add_kernel_parameter "amdgpu.ppfeaturemask=0xffffffff"

# Reloads systemd manager configuration
sudo systemctl daemon-reload

# Reads and applies kernel parameter settings
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Updates firmware
fwupdmgr refresh && fwupdmgr update

green_message "Tweaks complete."
