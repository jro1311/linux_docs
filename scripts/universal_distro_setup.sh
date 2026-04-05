#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

host_system="unknown"
os="unknown"
os_like="unknown"
debian_version=0
ubuntu_version=0
# linuxmint_version=0
fedora_version=0
# openmandriva_version=0
# opensuse_version=0
primary_package_manager="unknown"
secondary_package_manager="unknown"
flatpak_installed=0
snap_installed=0
toolbox_installed=0
desktop="unknown"
init_system="unknown"
root_filesystem="unknown"
home_filesystem="unknown"

# Sources all .sh files in $HOME/Documents/linux_docs/configs/system/bash/bashrc.d
shopt -s globstar nullglob

# shellcheck source=/dev/null
for rc in "$HOME"/Documents/linux_docs/configs/system/bash/bashrc.d/**/*.sh; do
    [[ -f "$rc" ]] && source "$rc"
done
unset rc

shopt -u globstar nullglob
shopt -s nullglob

# Prints system information
print_field "Host System" "$host_system"

if [ "$os_like" != "$os" ]; then
    print_field  "Base Distro(s)" "$os_like"
fi

print_field "Distro" "$os"

version="${VERSION_ID:-0}"
case "$os" in
    "debian"|"ubuntu"|"linuxmint"|"fedora"|"openmandriva"|"opensuse-leap")
        var="${os}_version"
        printf -v "$var" '%s' "$version"
        print_field "Distro Version" "$version"
        ;;
    *)
        # Extract primary ID_LIKE
        primary_like="${os_like%% *}"

        case "$primary_like" in
            "debian"|"fedora"|"ubuntu")
                var="${primary_like}_version"
                printf -v "$var" '%s' "$version"
                print_field "Base Version" "$version"
                ;;
        esac
        ;;
esac

print_field "Primary Package Manager" "$primary_package_manager"
print_field "Secondary Package Manager" "$secondary_package_manager"

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
    source_dir="$HOME/Documents/linux_docs/configs/system/bash/bashrc.d/"
    target_dir="$HOME/.bashrc.d/"

    if [ ! -d "$source_dir" ]; then
        red_message "Error:" "'$source_dir' does not exist."
        return 1
    fi

    # shellcheck disable=SC2016
    if ! grep -q '^# Sources all .sh files in $HOME/.bashrc.d$' "$HOME/.bashrc"; then
        cat "$HOME/Documents/linux_docs/configs/system/bash/bashrc" >> "$HOME/.bashrc"
        green_message "Enabled recursive sourcing in '$HOME/.bashrc.d'."
    fi

    if rsync -auhvP --delete "$source_dir" "$target_dir"; then
        green_message "Success:" "'$source_dir' synced with '$target_dir'"
    else
        red_message "Error:" "'$source_dir' failed to sync with '$target_dir'"
        return 1
    fi
}

if [[ -f /swapfile || -f /swap/swapfile || -f /swap.img ]]; then
    green_message "Detected:" "Swapfile"

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

    else
        enable_zswap
    fi
else
    yellow_message "Not detected:" "Swapfile"
fi

declare -A prompts=(
    [install_zram]="Install zram?"
    [install_codecs]="Install multimedia codecs?"
    [install_firefox_flatpak]="Install Firefox flatpak?"
    [install_redshift]="Install redshift?"
    [install_gaming_packages]="Install gaming packages?"
)

install_zram=0
install_codecs=0
install_firefox_flatpak=0
install_redshift=0
install_gaming_packages=0

for var in "${!prompts[@]}"; do
    if ask_for_confirmation "${prompts[$var]}"; then
        printf -v "$var" '%s' 1
    fi
done

read -r -p "Press enter to proceed, or ctrl+c to cancel: "

# Checks for wheel group and adds the current user to it
if getent group wheel >/dev/null 2>&1; then
    sudo usermod -aG wheel "$USER"
    green_message "'$USER' added to 'wheel' group."
fi

if [ "$root_filesystem" = "btrfs" ]; then

    root_cow_dirs=(
        /var/lib/flatpak
    )

    root_nocow_dirs=(
        /var/lib/libvirt/images
        /var/lib/machines
        /var/log/journal
    )

    # Enables COW on specific directory(s)
    for root_cow_dir in "${root_cow_dirs[@]}"; do
        sudo_run_passthrough mkdir -pv "${root_cow_dir[@]}" && sudo_run chattr -C "${root_cow_dir[@]}"
    done

    # Disables COW on specific directory(s)
    for root_nocow_dir in "${root_nocow_dirs[@]}"; do
        sudo_run_passthrough mkdir -pv "${root_nocow_dir[@]}" && sudo_run chattr +C "${root_nocow_dir[@]}"
    done

fi

if [ "$home_filesystem" = "btrfs" ]; then

    home_cow_dirs=(
        "$HOME/.local/share/flatpak"
    )

    home_nocow_dirs=(
        "$HOME/.local/share/gnome-boxes/images"
        "$HOME/.var/app/org.gnome.Boxes/data/gnome-boxes/images"
    )

    # Enables COW on specific directory(s)
    for home_cow_dir in "${home_cow_dirs[@]}"; do
        sudo_run_passthrough mkdir -pv "${home_cow_dir[@]}" && sudo_run chattr -C "${home_cow_dir[@]}"
    done

    # Disables COW on specific directory(s)
    for home_nocow_dir in "${home_nocow_dirs[@]}"; do
        sudo_run_passthrough mkdir -pv "${home_nocow_dir[@]}" && sudo_run chattr +C "${home_nocow_dir[@]}"
    done

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
)

solus_packages=(
    "cpu-x"
    "fastfetch"
    "fonts-installer"
    "micro"
    "nano-syntax-highlighting"
    "rocm-smi"
)

void_packages=(
    "CPU-X"
    "fastfetch"
    "hplip-gui"
    "memtest86+"
    "micro"
    "ROCm-SMI"
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
                install_yay
                yay -S --needed --noconfirm "${aur_packages[@]}"
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

if [ "$install_zram" -eq 1 ]; then
    install_zram
fi

if [ "$install_codecs" -eq 1 ]; then
    install_codecs
fi

if [ "$flatpak_installed" -eq 1 ]; then

    if flatpak remote-list | grep -Fq "fedora"; then
        flatpak remote-modify --disable fedora
        green_message "Disabled:" "Flatpak Fedora repository"
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
    green_message "Detected Partition(s):" "btrfs"
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

if [ "$install_redshift" -eq 1 ]; then
    install_redshift
fi

install_transmission

case "$desktop" in
    "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
        install_packages "${qt_packages[@]}"
        flatpak install flathub -y "${desktop_flatpaks[@]}"
        ;;
    "budgie"|"cosmic"|"deepin"|"pantheon"|"x-cinnamon")
        install_packages "${gtk_packages[@]}"
        flatpak install flathub -y "${desktop_flatpaks[@]}"
        ;;
    "gnome"|"ubuntu")
        install_packages "${gtk_packages[@]}" \
            "${gnome_packages[@]}"

        if [[ "$debian_version" -ge 13 ]] || ( echo "$ubuntu_version >= 25.10" | bc -l | grep -q "1" ); then
            sudo apt-get install -y  gnome-browser-connector gnome-shell-extension-manager

        elif echo "$ubuntu_version <= 24.04" | bc -l | grep -q "1"; then
            sudo apt-get install -y chrome-gnome-shell gnome-shell-extension-manager
        fi

        flatpak install flathub -y "${desktop_flatpaks[@]}" com.mattjakeman.ExtensionManager
        ;;
    "lxde"|"mate"|"unity")
        install_packages "${gtk_packages[@]}" \
        flatpak install flathub -y "${desktop_flatpaks[@]}"
        ;;
    "lxqt")
        install_packages "${qt_packages[@]}"
        flatpak install flathub -y "${desktop_flatpaks[@]}"
        ;;
    "kde"|"plasma")
        install_packages "${qt_packages[@]}"

        if command -v balooctl6 >/dev/null 2>&1; then
            balooctl6 disable
            green_message "Disabled: baloo"

        elif command -v balooctl >/dev/null 2>&1; then
            balooctl disable
            green_message "Disabled: baloo"
        fi
        ;;
    "xfce")
        install_packages "${gtk_packages[@]}" \
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
    add_kernel_parameter "preempt=lazy"
else
    add_kernel_parameter "preempt=full"
fi

# Adds firewall exceptions
if command -v firewall-cmd >/dev/null 2>&1; then
    zone="home"
    iface="wlp8s0"

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

case "$primary_package_manager" in
    "dnf")
        if grep -Fq "defaultyes" /etc/dnf/dnf.conf; then
            sudo sed -i '/defaultyes/d' /etc/dnf/dnf.conf
            echo "defaultyes = yes" | sudo tee -a /etc/dnf/dnf.conf
        else
            echo "defaultyes = yes" | sudo tee -a /etc/dnf/dnf.conf
        fi
        ;;
    "pacman")
        # Removes all cached versions of packages except the latest and one prior version
        sudo paccache -rk1

        # Enables timer to discard unused packages weekly
        if [ "$init_system" = "systemd" ]; then
            sudo systemctl enable --now paccache.timer
        fi
        ;;
esac

dirs=(
    "$HOME/.config/autostart"
    "$HOME/.config/btop"
    "$HOME/.config/fontconfig"
    "$HOME/.config/htop"
    "$HOME/.config/micro"
    "$HOME/.config/mpv"
    "$HOME/.config/nano"
    "$HOME/.var/app/io.mpv.Mpv/config/mpv"
    /etc/sysctl.d/
)

for dir in "${dirs[@]}"; do
    sudo_run_passthrough mkdir -pv "$dir"
done

enable_permanent_mac_address
sync_bashrc_configs

# Copies config(s) using a two array element pair loop
configs=(
    "$HOME/Documents/linux_docs/configs/applications/btop.conf" "$HOME/.config/btop/"
    "$HOME/Documents/linux_docs/configs/applications/htoprc" "$HOME/.config/htop/"
    "$HOME/Documents/linux_docs/configs/applications/micro/settings.json" "$HOME/.config/micro/"
    "$HOME/Documents/linux_docs/configs/applications/mpv" "$HOME/.config/"
    "$HOME/Documents/linux_docs/configs/applications/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"
    "$HOME/Documents/linux_docs/configs/applications/nanorc" "$HOME/.config/nano/"
    "$HOME/Documents/linux_docs/configs/system/fontconfig/fonts.conf" "$HOME/.config/fontconfig/"
    "$HOME/Documents/linux_docs/configs/applications/nanorc" /etc/nanorc
)

for ((i=0; i<${#configs[@]}; i+=2)); do
    sudo_run_passthrough cp -rv "${configs[i]}" "${configs[i+1]}"
done

if [ "$host_system" = "laptop" ]; then

    # Edits mpv profile from high quality to fast
    sed -i 's/profile=high-quality/profile=fast/' "$HOME/.config/mpv/mpv.conf"
    sed -i 's/profile=high-quality/profile=fast/' "$HOME/.var/app/io.mpv.Mpv/config/mpv/mpv.conf"

fi

if [ "$install_zram" -eq 1 ]; then

    # Replaces swap meter with zram in htop
    sed -i 's/Swap/Zram/g' "$HOME/.config/htop/htoprc"

fi

# Reloads systemd manager configuration
if [ "$init_system" = "systemd" ]; then
    sudo systemctl daemon-reload
fi
    
green_message "Success:" "Setup is now complete. Reboot to apply all changes."
