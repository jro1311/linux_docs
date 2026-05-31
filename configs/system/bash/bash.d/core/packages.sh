#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2154

universal_pkgs=(
    bash-completion
    bat
    btop
    curl
    dos2unix
    flatpak
    fontconfig
    fwupd
    gawk
    git
    gnome-disk-utility
    gsmartcontrol
    hplip
    htop
    inxi
    jq
    mpv
    nano
    ntfs-3g
    pciutils
    perl
    rsync
    shellcheck
    smartmontools
    speedtest-cli
    tealdeer
    yt-dlp
    zstd
)

arch_pkgs=(
    linux-lts
    memtest86+
    nano-syntax-highlighting
    shfmt
)

aur_pkgs=(
    ttf-ms-win11-auto
)

debian_pkgs=(
    hplip-gui
    memtest86+
    nala
    shfmt
    ttf-mscorefonts-installer
)

fedora_pkgs=(
    cabextract
    google-noto-sans-jp-fonts
    google-noto-sans-kr-fonts
    hplip-gui
    memtest86+
    shfmt
    xorg-x11-font-utils
)

openmandriva_pkgs=(
    fonts-ttf-japanese
    fonts-ttf-korean
    hplip-gui
    memtest86+
)

opensuse_pkgs=(
    fetchmsttfonts
    grub2-snapper-plugin
    memtest86+
    setroubleshoot
    shfmt
)

solus_pkgs=(
    fonts-installer
    nano-syntax-highlighting
)

void_pkgs=(
    hplip-gui
    memtest86+
    shfmt
)

atomic_pkgs=(
    btop
    fastfetch
    gnome-disk-utility
    hplip
    hplip-gui
    htop
    inxi
    rocm-smi
    smartmontools
)

toolbox_pkgs=(
    bash-completion
    bat
    curl
    dos2unix
    git
    jq
    micro
    nano
    rsync
    shellcheck
    shfmt
    tealdeer
    yt-dlp
    zstd
)

gtk_pkgs=(
    gnome-clocks
    gnome-weather
)

qt_pkgs=(
    kclock
    kweather
)

gnome_pkgs=(
    gnome-tweaks
)

debian_gnome_pkgs=(
    gnome-browser-connector
    gnome-shell-extension-manager
)

xfce_pkgs=(
    xfce4-whiskermenu-plugin
)

atomic_flatpaks=(
    io.github.thetumultuousunicornofdarkness.cpu-x
    io.mpv.Mpv
)

flatpaks=(
    org.mersenne.mprime
    com.obsproject.Studio
    com.usebottles.bottles
    io.github.mhogomchungu.media-downloader
    com.discordapp.Discord
    com.spotify.Client
)

gaming_flatpaks=(
    com.geeks3d.furmark
    com.vysp3r.ProtonPlus
    com.github.Matoking.protontricks
    com.heroicgameslauncher.hgl
    org.prismlauncher.PrismLauncher
)

remove_list_apt=(
    firefox-esr
    firefox
    libreoffice*
)

remove_list_dnf=(
    chromium
    firefox
    libreoffice*
)

remove_list_eopkg=(
    firefox
    libreoffice*
)

remove_list_pacman=(
    firefox
    libreoffice*
)

remove_list_xbps=(
    firefox
    libreoffice*
)

remove_list_zypper=(
    MozillaFirefox
    vlc
    libreoffice*
)

remove_list_rpm_ostree=(
    firefox firefox-langpacks
    libreoffice
)

remove_list_snap=(
    firefox
)

declare -A bibata_cursor_pkg=(
    [apt]="bibata-cursor-theme"
    [dnf]="bibata-cursor-theme"
    [eopkg]="bibata-cursors"
    [pacman]="bibata-cursor-theme"
    [xbps]=""
    [zypper]=""
    [rpm-ostree]="bibata-cursor-theme"
)

declare -A compsize_pkg=(
    [apt]="btrfs-compsize"
    [dnf]="compsize"
    [eopkg]="compsize"
    [pacman]="compsize"
    [xbps]="compsize"
    [zypper]="compsize"
    [rpm-ostree]="compsize"
)

declare -A cpux_pkg=(
    [apt]="cpu-x"
    [dnf]="cpu-x"
    [eopkg]="cpu-x"
    [pacman]="cpu-x"
    [xbps]="CPU-X"
    [zypper]="cpu-x"
    [rpm-ostree]="cpu-x"
)

declare -A dmz_cursor_pkg=(
    [apt]="dmz-cursor-theme"
    [dnf]=""
    [eopkg]="dmz-cursor-theme"
    [pacman]=""
    [xbps]=""
    [zypper]="dmz-icon-theme-cursors"
    [rpm-ostree]=""
)

declare -A elementary_icons_pkg=(
    [apt]="elementary-icon-theme"
    [dnf]="elementary-icon-theme"
    [eopkg]=""
    [pacman]="elementary-icon-theme"
    [xbps]=""
    [zypper]="pantheon-icons"
    [rpm-ostree]="elementary-icon-theme"
)

declare -A greybird_theme_pkg=(
    [apt]="greybird-gtk-theme"
    [dnf]="greybird-dark-theme greybird-light-theme"
    [eopkg]=""
    [pacman]=""
    [xbps]="greybird-themes"
    [zypper]="metatheme-greybird-common"
    [rpm-ostree]="greybird-dark-theme greybird-light-theme"
)

declare -A lact_pkg=(
    [apt]=""
    [dnf]="lact"
    [eopkg]="lact"
    [pacman]="lact"
    [xbps]="LACT"
    [zypper]="lact"
    [rpm-ostree]="lact"
)

declare -A mangohud_pkg=(
    [apt]="mangohud"
    [dnf]="mangohud"
    [eopkg]="mangohud"
    [pacman]="mangohud lib32-mangohud"
    [xbps]="MangoHud MangoHud-32bit"
    [zypper]="mangohud"
    [rpm-ostree]="mangohud"
)

declare -A micro_pkg=(
    [apt]="micro"
    [dnf]="micro"
    [eopkg]="micro"
    [pacman]="micro"
    [xbps]="micro"
    [zypper]="micro-editor"
    [rpm-ostree]="micro"
)

declare -A redshift_pkg=(
    [apt]="redshift-gtk"
    [dnf]="redshift-gtk"
    [eopkg]="redshift-gtk"
    [pacman]="redshift"
    [xbps]="redshift-gtk"
    [zypper]="redshift-gtk"
    [rpm-ostree]="redshift-gtk"
)

declare -A transmission_gtk_pkg=(
    [apt]="transmission-gtk"
    [dnf]="transmission-gtk"
    [eopkg]="transmission"
    [pacman]="transmission-gtk"
    [xbps]="transmission-gtk"
    [zypper]="transmission-gtk"
    [rpm-ostree]="transmission-gtk"
)

declare -A transmission_qt_pkg=(
    [apt]="transmission-qt"
    [dnf]="transmission-qt"
    [eopkg]="transmission"
    [pacman]="transmission-qt"
    [xbps]="transmission-qt"
    [zypper]="transmission-qt"
    [rpm-ostree]="transmission-qt"
)

declare -A rocm_smi_pkg=(
    [apt]="rocm-smi"
    [dnf]="rocm-smi"
    [eopkg]="rocm-smi"
    [pacman]="rocm-smi-lib"
    [xbps]="ROCm-SMI"
    [zypper]="rocm-smi"
    [rpm-ostree]="rocm-smi"
)

declare -A steam_pkg=(
    [apt]="steam-installer"
    [dnf]="steam"
    [eopkg]="steam"
    [pacman]="steam"
    [xbps]="steam"
    [zypper]="steam"
    [rpm-ostree]="steam"
)

declare -A ubuntu_fonts_pkg=(
    [apt]=""
    [dnf]=""
    [eopkg]="font-ubuntu-sans-ttf font-ubuntu-ttf"
    [pacman]="ttf-ubuntu-font-family"
    [xbps]="ttf-ubuntu-font-family"
    [zypper]=""
    [rpm-ostree]=""
)

declare -A zram_pkg=(
    [apt]="systemd-zram-generator"
    [dnf]="zram-generator"
    [eopkg]="zram-generator"
    [pacman]="zram-generator"
    [xbps]="zramen"
    [zypper]="zram-generator"
    [rpm-ostree]="zram-generator"
)
