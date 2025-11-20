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

# Check for Flatpak
flatpak_installed=0
if command -v flatpak >/dev/null 2>&1; then
    flatpak_installed=1
    green_message "Flatpak detected."
fi

# Check for Snap
snap_installed=0
if command -v snap >/dev/null 2>&1; then
    snap_installed=1
    green_message "Snap detected."
fi

# Check for Toolbox
toolbox_installed=0
if command -v toolbox >/dev/null 2>&1; then
    toolbox_installed=1
    green_message "Toolbox detected."
fi

# Define the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')
green_message "Desktop: $desktop"

# Define init system
init_system="unknown"
init_names=(systemd runit sysvinit openrc-init)
pid1_comm=$(ps -p 1 -o comm=)

for init_name in "${init_names[@]}"; do
    if [ "$pid1_comm" = "$init_name" ]; then
        init_system="$init_name"
        break
    fi
done

if [ "$init_system" != "unknown" ]; then
    green_message "Init System: $init_system"
fi

# Define file system of root directory
root_filesystem="$(df -T / | awk 'NR==2 {print $2}')"
green_message "Root File System: $root_filesystem"

# Define file system of home directory
home_filesystem="$(df -T /home | awk 'NR==2 {print $2}')"
green_message "Home File System: $home_filesystem"

remove_firefox() {
    case "$primary_package_manager" in
        "apt")
            check firefox-esr \
                sudo apt-get remove -y firefox-esr
            check /usr/bin/firefox \
                sudo apt-get remove -y firefox
            check /snap/bin/firefox \
                sudo snap remove firefox
            ;;
        "dnf")
            check firefox \
                sudo dnf remove -y firefox
            ;;
        "eopkg")
            check firefox \
                sudo eopkg remove -y firefox
            ;;
        "pacman")
            check firefox \
                sudo pacman -Rs --noconfirm firefox
            ;;
        "xbps")
            check firefox \
                sudo xbps-remove -Ry firefox
            ;;
        "zypper")
            check MozillaFirefox \
                sudo zypper rm --clean-deps -y MozillaFirefox
            ;;
        "rpm-ostree")
            check firefox \
                sudo rpm-ostree override remove firefox firefox-langpacks
            ;;
    esac
}

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

if [[ -f /swapfile || -f /swap/swapfile || -f /swap.img ]]; then
    green_message "Swapfile detected."

    if ask_for_confirmation "Remove swapfile?"; then

        # Removes detected swapfile
        if [ -f /swapfile ]; then
            sudo swapoff /swapfile
            sudo rm -v /swapfile
            sudo sed -i '/\/swapfile/d' /etc/fstab

        elif [ -f /swap/swapfile ]; then
            sudo swapoff /swap/swapfile
            sudo rm -v /swap/swapfile
            sudo sed -i '/\/swap\/swapfile/d' /etc/fstab

            if [ "$root_filesystem" = "btrfs" ]; then
                sudo btrfs subvolume delete /swap
            fi

        elif [ -f /swap.img ]; then
            sudo swapoff /swap.img
            sudo rm -v /swap.img
            sudo sed -i '/\/swap.img/d' /etc/fstab
        fi

    fi
else
    yellow_message "No swapfile detected."
fi

install_firefox_flatpak=0
install_codecs=0
install_gaming_packages=0
autostart_transmission=0

if ask_for_confirmation "Install Firefox flatpak?"; then
    install_firefox_flatpak=1
fi

if ask_for_confirmation "Install multimedia codecs?"; then
    install_codecs=1
fi

if ask_for_confirmation "Install gaming packages?"; then
    install_gaming_packages=1
fi

if ask_for_confirmation "Add Transmission to autostart?"; then
    autostart_transmission=1
fi

read -r -p "Press enter to proceed, or ctrl+c to cancel: "

# Checks for wheel group and adds the current user to it
if getent group wheel >/dev/null 2>&1; then
    sudo usermod -aG wheel "$USER"
    green_message "'$USER' added to 'wheel' group."
fi

if [ "$root_filesystem" = "btrfs" ]; then

    # Makes directory(s)
    sudo mkdir -pv /var/lib/flatpak
    sudo mkdir -pv /var/lib/libvirt/images
    sudo mkdir -pv /var/lib/machines
    sudo mkdir -pv /var/log/journal

    # Enables COW on specific directory(s)
    sudo chattr -C /var/lib/flatpak

    # Disables COW on specific directory(s)
    sudo chattr +C /var/lib/libvirt/images
    sudo chattr +C /var/lib/machines
    sudo chattr +C /var/log/journal

fi

if [ "$home_filesystem" = "btrfs" ]; then

    mkdir -pv "$HOME/.local/share/flatpak"
    mkdir -pv "$HOME/.local/share/gnome-boxes/images"
    mkdir -pv "$HOME/.var/app/org.gnome.Boxes/data/gnome-boxes/images"

    # Enables COW on specific directory(s)
    chattr -C "$HOME/.local/share/flatpak"

    # Disables COW on specific directory(s)
    chattr +C "$HOME/.local/share/gnome-boxes/images"
    chattr +C "$HOME/.var/app/org.gnome.Boxes/data/gnome-boxes/images"

fi

if [ "$install_firefox_flatpak" -eq 1 ]; then
    remove_firefox
fi

case "$primary_package_manager" in
    "apt")
        check libreoffice \
            sudo apt-get remove -y libreoffice*
        ;;
    "dnf")
        [ "$os" = "openmandriva" ] && check chromium \
            sudo dnf remove -y chromium

        check libreoffice \
            sudo dnf remove -y libreoffice*
        ;;
    "eopkg")
        check libreoffice \
            sudo eopkg remove -y libreoffice*
        ;;
    "pacman")
        check libreoffice \
            sudo pacman -Rs --noconfirm libreoffice*
        ;;
    "xbps")
        check libreoffice \
            sudo xbps-remove -Ry libreoffice*
        ;;
    "zypper")
        check vlc \
            sudo zypper rm --clean-deps -y vlc
        check libreoffice \
            sudo zypper rm --clean-deps -y libreoffice*
        ;;
    "rpm-ostree")
        check libreoffice \
            sudo rpm-ostree override remove libreoffice
        ;;
esac

case "$primary_package_manager" in
    "apt")
        sudo apt-get update && sudo apt-get full-upgrade -y
        ;;
    "dnf")
        sudo dnf upgrade -y
        ;;
    "eopkg")
        sudo eopkg upgrade -y
        ;;
    "pacman")
        case "$secondary_package_manager" in
            "paru"|"yay")
                "$secondary_package_manager" -Syu --noconfirm
                ;;
            *)
                sudo pacman -Syu --noconfirm
                ;;
        esac
        ;;
    "xbps")
        sudo xbps-install -Suy xbps && sudo xbps-install -uy
        ;;
    "zypper")
        case "$os" in
            "opensuse-tumbleweed"|"opensuse-slowroll")
                sudo zypper ref && sudo zypper dup -y
                ;;
            "opensuse-leap")
                sudo zypper ref && sudo zypper up -y
                ;;
        esac
        ;;
    "rpm-ostree")
        sudo rpm-ostree upgrade
        ;;
esac

if [ "$flatpak_installed" -eq 1 ]; then
    flatpak update -y
fi

if [ "$snap_installed" -eq 1 ]; then
    sudo snap refresh
fi

case "$os" in
    "debian")
        enable_debian_contrib
        enable_debian_backports
        ;;
    "ubuntu")
        # Prevents Debian-specific commands from running on Ubuntu
        ;;
    *)
        case "$os_like" in
            "debian")
                enable_debian_contrib
                enable_debian_backports
                ;;
        esac
    ;;
esac

# List of universal packages
universal_packages=(
"bash-completion"
"btop"
"curl"
"dos2unix"
"flatpak"
"fontconfig"
"fwupd"
"gawk"
"git"
"gnome-boxes"
"gnome-disk-utility"
"gsmartcontrol"
"hplip"
"htop"
"inxi"
"jq"
"mpv"
"nano"
"ntfs-3g"
"pciutils"
"perl"
"shellcheck"
"smartmontools"
"tealdeer"
"yt-dlp"
)

# List of distro-specific packages
arch_packages=(
"cpu-x"
"fastfetch"
"linux-lts"
"memtest86+"
"micro"
"rocm-smi-lib"
"zram-generator"
)

aur_packages=(
"nano-syntax-highlighting"
"ttf-ms-win11-auto"
)

debian_packages=(
"cpu-x"
"hplip-gui"
"memtest86+"
"micro"
"nala"
"neofetch"
"rocm-smi"
"systemd-zram-generator"
"ttf-mscorefonts-installer"
)

atomic_packages=(
"gnome-disk-utility"
"hplip"
"hplip-gui"
)

fedora_packages=(
"cabextract"
"cpu-x"
"fastfetch"
"google-noto-sans-jp-fonts"
"google-noto-sans-kr-fonts"
"hplip-gui"
"memtest86+"
"micro"
"rocm-smi"
"xorg-x11-font-utils"
"zram-generator"
)

openmandriva_packages=(
"cpu-x"
"fastfetch"
"fonts-ttf-japanese"
"fonts-ttf-korean"
"hplip-gui"
"memtest86+"
"micro"
"rocm-smi"
"zram-generator"
)

opensuse_packages=(
"cpu-x"
"fastfetch"
"fetchmsttfonts"
"grub2-snapper-plugin"
"memtest86+"
"micro-editor"
"rocm-smi"
"setroubleshoot"
"zram-generator")

solus_packages=(
"cpu-x"
"fastfetch"
"fonts-installer"
"micro"
"nano-syntax-highlighting"
"rocm-smi"
"zram-generator"
)

void_packages=(
"CPU-X"
"fastfetch"
"hplip-gui"
"memtest86+"
"micro"
"ROCm-SMI"
"zramen"
)

toolbox_packages=(
"btop"
"dos2unix"
"fastfetch"
"git"
"htop"
"inxi"
"micro"
"nano"
"rocm-smi"
"shellcheck"
"smartmontools"
"tealdeer"
"yt-dlp"
)

# List of flatpaks
atomic_flatpaks=(
"com.transmissionbt.Transmission"
"io.github.thetumultuousunicornofdarkness.cpu-x"
"io.mpv.Mpv"
"org.gnome.Boxes"
)

flatpaks=(
"com.bitwarden.desktop"
"com.discordapp.Discord"
"com.spotify.Client"
"io.github.mhogomchungu.media-downloader"
"org.libreoffice.LibreOffice"
)

case "$primary_package_manager" in
    "apt")
        sudo apt-get install -y "${universal_packages[@]}" "${debian_packages[@]}" && flatpak_installed=1
        ;;
    "dnf")
        if [ "$os" = "openmandriva" ]; then
            sudo dnf install -y "${universal_packages[@]}" "${openmandriva_packages[@]}" && flatpak_installed=1
        else
            sudo dnf install -y "${universal_packages[@]}" "${fedora_packages[@]}" && flatpak_installed=1
        fi
        ;;
    "eopkg")
        sudo eopkg install -y "${universal_packages[@]}" "${solus_packages[@]}" && flatpak_installed=1
        ;;
    "pacman")
        sudo pacman -S --needed --noconfirm "${universal_packages[@]}" "${arch_packages[@]}" && flatpak_installed=1

        enable_chaotic_aur
        case "$secondary_package_manager" in
            "paru"|"yay")
                "$secondary_package_manager" -S --needed --noconfirm "${aur_packages[@]}"
                ;;
            *)
                install_paru
                paru -S --needed --noconfirm "${aur_packages[@]}"
                ;;
        esac
        ;;
    "xbps")
        sudo xbps-install -Sy "${universal_packages[@]}" "${void_packages[@]}" && flatpak_installed=1
        ;;
    "zypper")
        sudo zypper in -y "${universal_packages[@]}" "${opensuse_packages[@]}" && flatpak_installed=1
        ;;
    "rpm-ostree")
        sudo rpm-ostree install "${atomic_packages[@]}"

        # Sets up toolbox container
        if [ "$toolbox_installed" -eq -1 ]; then

            if ! toolbox list | grep -Fq "fedora-toolbox-$fedora_version"; then
                toolbox create --distro fedora --release "$fedora_version"
            fi

            toolbox run sudo dnf upgrade -y && toolbox run sudo dnf install -y "${toolbox_packages[@]}"
        fi
        ;;
    *)
        unsupported_package_manager
        exit 1
        ;;
esac

# Installs Deno (JavaScript runtime)
curl -fsSL https://deno.land/install.sh | sh

install_fonts_microsoft

if [ "$install_codecs" -eq 1 ]; then
    install_codecs
fi

if [ "$flatpak_installed" -eq 1 ]; then

    if flatpak remote-list | grep -Fq "fedora"; then
        flatpak remote-modify --disable fedora
        green_message "Flatpak: Disabled Fedora repository"
    else
        yellow_message "Flatpak: No Fedora repository detected"
    fi

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    if [ "$install_firefox_flatpak" -eq 1 ]; then
        flatpak install flathub -y org.mozilla.firefox
    fi

    if [ "$primary_package_manager" = "rpm-ostree" ]; then
        flatpak install flathub -y "${atomic_flatpaks[@]}"
    fi

    flatpak install flathub -y "${flatpaks[@]}"

fi

case "$primary_package_manager" in
    "rpm-ostree"|"xbps")
        flatpak install flathub -y com.brave.Browser
        ;;
    *)
        curl -fsS https://dl.brave.com/install.sh | sh
        ;;
esac

if mount | grep -Fq "type btrfs"; then
    green_message "Detected Partition(s): btrfs"

    declare -A compsize=(
    [apt]="btrfs-compsize"
    [dnf]="compsize"
    [eopkg]="compsize"
    [pacman]="compsize"
    [xbps]="compsize"
    [zypper]="compsize"
    [rpm-ostree]="compsize"
    )

    install_packages "${compsize[$primary_package_manager]}"

    if [ "$init_system" = "systemd" ]; then
        install_btrfsmaintenance
    fi
else
    yellow_message "No btrfs partitions detected."
fi

gtk_packages=(
"gnome-clocks"
"gnome-weather"
)

qt_packages=(
"kclock"
"kweather"
)

gnome_packages=(
"gnome-tweaks"
)

xfce_packages=(
"xfce4-whiskermenu-plugin"
)

desktop_flatpaks=(
"com.github.tchx84.Flatseal"
)

declare -A transmission_gtk=(
    [apt]="transmission-gtk"
    [dnf]="transmission-gtk"
    [eopkg]="transmission"
    [pacman]="transmission-gtk"
    [xbps]="transmission-gtk"
    [zypper]="transmission-gtk"
)

declare -A transmission_qt=(
    [apt]="transmission-qt"
    [dnf]="transmission-qt"
    [eopkg]="transmission"
    [pacman]="transmission-qt"
    [xbps]="transmission-qt"
    [zypper]="transmission-qt"
)

declare -A redshift=(
    [apt]="redshift-gtk"
    [dnf]="redshift-gtk"
    [eopkg]="redshift"
    [pacman]="redshift"
    [xbps]="redshift-gtk"
    [zypper]="redshift-gtk"
)

case "$desktop" in
    "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
        install_packages \
            "${qt_packages[@]}" \
            "${transmission_qt[$primary_package_manager]}" \
            "${redshift[$primary_package_manager]}"

        flatpak install flathub -y "${desktop_flatpaks[@]}"
        ;;
    "budgie"|"cosmic"|"deepin"|"pantheon"|"x-cinnamon")
        install_packages \
            "${gtk_packages[@]}" \
            "${transmission_gtk[$primary_package_manager]}"

        flatpak install flathub -y "${desktop_flatpaks[@]}"
        ;;
    "gnome"|"ubuntu")
        install_packages \
            "${gtk_packages[@]}" \
            "${transmission_gtk[$primary_package_manager]}" \
            "${gnome_packages[@]}"

        if [[ "$debian_version" -ge 13 ]] || ( echo "$ubuntu_version >= 25.10" | bc -l | grep -q 1 ); then
            sudo apt-get install -y  gnome-browser-connector gnome-shell-extension-manager

        elif echo "$ubuntu_version <= 24.04" | bc -l | grep -q 1; then
            sudo apt-get install -y chrome-gnome-shell gnome-shell-extension-manager
        fi

        flatpak install flathub -y "${desktop_flatpaks[@]}" com.mattjakeman.ExtensionManager

        gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate']"
        green_message "Enabled: Variable Refresh Rate"
        ;;
    "lxde"|"mate"|"unity")
        install_packages \
            "${gtk_packages[@]}" \
            "${transmission_gtk[$primary_package_manager]}" \
            "${redshift[$primary_package_manager]}"

        flatpak install flathub -y "${desktop_flatpaks[@]}"
        ;;
    "lxqt")
        install_packages \
            "${qt_packages[@]}" \
            "${transmission_qt[$primary_package_manager]}" \
            "${redshift[$primary_package_manager]}"

        flatpak install flathub -y "${desktop_flatpaks[@]}"
        ;;
    "kde"|"plasma")
        install_packages \
            "${qt_packages[@]}" \
            "${transmission_qt[$primary_package_manager]}"

        if command -v balooctl6 >/dev/null 2>&1; then
            balooctl6 disable
            green_message "Disabled: baloo"

        elif command -v balooctl >/dev/null 2>&1; then
            balooctl disable
            green_message "Disabled: baloo"
        fi
        ;;
    "xfce")
        install_packages \
            "${gtk_packages[@]}" \
            "${transmission_gtk[$primary_package_manager]}" \
            "${redshift[$primary_package_manager]}" \
            "${xfce_packages[@]}"

        flatpak install flathub -y "${desktop_flatpaks[@]}"
        ;;
    *)
        unsupported_desktop
        exit 1
        ;;
esac

if [ "$install_gaming_packages" -eq 1 ]; then
    install_gaming_meta
fi

if [ "$host_system" = "laptop" ]; then
    add_kernel_argument "preempt=lazy"
else
    add_kernel_argument "preempt=full"
fi

# Adds firewall exceptions
if command -v firewall-cmd >/dev/null 2>&1; then
    zone=home
    iface=wlp8s0

    sudo firewall-cmd --add-interface="$iface" --zone="$zone"
    sudo firewall-cmd --set-default-zone="$zone"

    # Services to enable
    services=(
        bittorrent-lsd dhcp dhcpv6 dhcpv6-client dns dns-over-quic dns-over-tls
        http http3 mdns samba-client slp spotify-sync ssh terraria transmission-client
    )

    for svc in "${services[@]}"; do
        sudo firewall-cmd --zone="$zone" --add-service="$svc" --permanent
    done

    # Ports to enable
    ports=(
        161-162/tcp 9100/tcp
        161-162/udp 9100/udp
    )

    for port in "${ports[@]}"; do
        sudo firewall-cmd --zone="$zone" --add-port="$port" --permanent
    done

    sudo firewall-cmd --reload
fi

# Adds option(s) to dnf configuration
if [ "$primary_package_manager"  = "dnf" ]; then
    if grep -Fq "defaultyes" /etc/dnf/dnf.conf; then

        sudo sed -i '/defaultyes/d' /etc/dnf/dnf.conf
        echo "defaultyes = yes" | sudo tee -a /etc/dnf/dnf.conf

    else
        echo "defaultyes = yes" | sudo tee -a /etc/dnf/dnf.conf
    fi
fi

if [ "$primary_package_manager" = "pacman" ]; then

    # Removes all cached versions of packages except the latest and one prior version
    sudo paccache -rk1

    # Enables timer to discard unused packages weekly
    if [ "$init_system" = "systemd" ]; then
        sudo systemctl enable --now paccache.timer
    fi

fi

home_dirs=(
    "$HOME/.config/autostart"
    "$HOME/.config/btop"
    "$HOME/.config/fontconfig"
    "$HOME/.config/htop"
    "$HOME/.config/micro"
    "$HOME/.config/mpv"
    "$HOME/.config/nano"
    "$HOME/.var/app/io.mpv.Mpv/config/mpv"
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

if command -v redshift-gtk >/dev/null 2>&1 || command -v redshift >/dev/null 2>&1; then
    cp -v "$HOME/Documents/linux_docs/configs/applications/redshift/redshift.conf" "$HOME/.config/"

    # Define coordinates
    location=$(curl -s "http://ipinfo.io/$(curl -s api.ipify.org)/json")
    latitude=$(echo "$location" | jq -r '.loc' | cut -d',' -f1)
    longitude=$(echo "$location" | jq -r '.loc' | cut -d',' -f2)

    # Adds coordinates to config(s)
    echo "lat=$latitude" >> "$HOME/.config/redshift.conf"
    echo "lon=$longitude" >> "$HOME/.config/redshift.conf"

    # Adds package(s) to autostart
    cp -v "$HOME/Documents/linux_docs/configs/applications/redshift/redshift.desktop" "$HOME/.config/autostart/"
fi

if command -v redshift-gtk >/dev/null 2>&1; then
    echo "Exec=redshift-gtk" >> "$HOME/.config/autostart/redshift.desktop"

elif command -v redshift >/dev/null 2>&1; then
    echo "Exec=redshift" >> "$HOME/.config/autostart/redshift.desktop"
fi

if [ "$autostart_transmission" -eq 1 ]; then
    cp -v "$HOME/Documents/linux_docs/configs/applications/transmission.desktop" "$HOME/.config/autostart/"

    if command -v transmission-gtk >/dev/null 2>&1; then
        echo "Exec=transmission-gtk --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"

    elif command -v transmission-qt >/dev/null 2>&1; then
        echo "Exec=transmission-qt --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"

    elif [ "$flatpak_installed" -eq 1 ] && flatpak list | grep -Fq "com.transmissionbt.Transmission"; then
        echo "Exec=flatpak run com.transmissionbt.Transmission --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"
    fi
fi

enable_permanent_mac_address
sync_bashrc_configs

# Copies config(s) using a two array element pair loop
home_configs=(
    "$HOME/Documents/linux_docs/configs/applications/btop.conf" "$HOME/.config/btop/"
    "$HOME/Documents/linux_docs/configs/applications/htoprc" "$HOME/.config/htop/"
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

case "$init_system" in
    "systemd")
        sudo cp -v "$HOME/Documents/linux_docs/configs/system/zram/zram-generator.conf" /etc/systemd/

        if [ "$host_system" = "laptop" ]; then

            # Changes zram compression algorithm from zstd to lz4
            sudo sed -i 's/zstd/lz4/g' /etc/systemd/zram-generator.conf

            # Edits mpv profile from high quality to fast
            sed -i 's/profile=high-quality/profile=fast/' "$HOME/.config/mpv/mpv.conf"
            sed -i 's/profile=high-quality/profile=fast/' "$HOME/.var/app/io.mpv.Mpv/config/mpv/mpv.conf"

        fi
        ;;
    "runit")
        if zramctl /dev/zram* >/dev/null 2>&1; then
            sudo zramen toss
        fi

        # Creates zram swap device with same size as RAM
        algo="unknown"
        size="100"
        if [ "$host_system" = "laptop" ]; then
            algo="lz4"
        else
            algo="zstd"
        fi

        sudo zramen make -a "$algo" -s "$size"

        # Adds command(s) to boot sequence
        if ! grep -Fq "zramen" /etc/rc.local; then
            echo "zramen make -a $algo -s $size" | sudo tee -a /etc/rc.local
        fi
        ;;
    *)
        unsupported_init_system
        exit 1
        ;;
esac

# Reloads systemd manager configuration and starts zram device
if [ "$init_system" = "systemd" ]; then
    sudo systemctl daemon-reload

    if systemctl list-units | grep -Fq "systemd-zram-setup@zram0.service"; then
        sudo systemctl start systemd-zram-setup@zram0.service
    fi
fi

# Reads and applies kernel parameter settings
sudo sysctl -p /etc/sysctl.d/99-zram.conf
    
green_message "Setup is now complete. Reboot to apply all changes."
