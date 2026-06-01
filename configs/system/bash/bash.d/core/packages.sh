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

unset -v firefox_native_pkgs
unset -v firefox_flatpak_pkgs
unset -v firefox_snap_pkgs

unset -v chromium_native_pkgs
unset -v chromium_flatpak_pkgs
unset -v chromium_snap_pkgs

unset -v password_manager_native_pkgs
unset -v password_manager_flatpak_pkgs
unset -v password_manager_snap_pkgs

unset -v office_suite_native_pkgs
unset -v office_suite_flatpak_pkgs
unset -v office_suite_snap_pkgs

unset -v text_editor_native_pkgs
unset -v text_editor_flatpak_pkgs
unset -v text_editor_snap_pkgs

unset -v video_editor_native_pkgs
unset -v video_editor_flatpak_pkgs
unset -v video_editor_snap_pkgs

unset -v torrent_client_native_pkgs
unset -v torrent_client_flatpak_pkgs
unset -v torrent_client_snap_pkgs

unset -v vm_application_native_pkgs
unset -v vm_application_flatpak_pkgs
unset -v vm_application_snap_pkgs

unset -v gpu_config_tool_native_pkgs
unset -v gpu_config_tool_flatpak_pkgs
unset -v gpu_config_tool_snap_pkgs

declare -A firefox_native_pkgs=(
    [MozillaFirefox]="MozillaFirefox"
    [firefox-esr]="firefox-esr"
    [firefox]="firefox"
    [librewolf]="librewolf"
    [floorp]="floorp"
    [zen]="zen"
    [waterfox]="waterfox"
)

declare -A firefox_flatpak_pkgs=(
    [MozillaFirefox]=""
    [firefox-esr]=""
    [firefox]="org.mozilla.firefox"
    [librewolf]="io.gitlab.librewolf-community"
    [floorp]="one.ablaze.floorp"
    [zen]="app.zen_browser.zen"
    [waterfox]="net.waterfox.waterfox"
)

declare -A firefox_snap_pkgs=(
    [MozillaFirefox]=""
    [firefox-esr]=""
    [firefox]="firefox"
    [librewolf]=""
    [floorp]="floorp"
    [zen]="zen-browser-snap"
    [waterfox]=""
)

declare -A chromium_native_pkgs=(
    [brave]="brave-browser"
    [chromium]="chromium"
    [ungoogled-chromium]="ungoogled-chromium"
    [vivaldi]="vivaldi-stable"
    [chrome]="google-chrome-stable"
    [opera]="opera"
    [opera-gx]="opera-gx"
)

declare -A chromium_flatpak_pkgs=(
    [brave]="com.brave.Browser"
    [chromium]="org.chromium.Chromium"
    [ungoogled-chromium]="io.github.ungoogled_software.ungoogled_chromium"
    [vivaldi]="com.vivaldi.Vivaldi"
    [chrome]="com.google.Chrome"
    [opera]="com.opera.Opera"
    [opera-gx]="com.opera.opera-gx"
)

declare -A chromium_snap_pkgs=(
    [brave]="brave"
    [chromium]="chromium"
    [ungoogled-chromium]=""
    [vivaldi]="vivaldi"
    [chrome]=""
    [opera]="opera"
    [opera-gx]="opera-gx"
)

declare -A password_manager_native_pkgs=(
    [bitwarden]="bitwarden"
    [keepassxc]="keepassxc"
)

declare -A password_manager_flatpak_pkgs=(
    [bitwarden]="com.bitwarden.desktop"
    [keepassxc]="org.keepassxc.KeePassXC"
)

declare -A password_manager_snap_pkgs=(
    [bitwarden]="bitwarden"
    [keepassxc]="keepassxc"
)

declare -A office_suite_native_pkgs=(
    [libreoffice]="libreoffice"
    [onlyoffice]=""
)

declare -A office_suite_flatpak_pkgs=(
    [libreoffice]="org.libreoffice.LibreOffice"
    [onlyoffice]="org.onlyoffice.desktopeditors"
)

declare -A office_suite_snap_pkgs=(
    [libreoffice]="libreoffice"
    [onlyoffice]="onlyoffice-desktopeditors"
)

declare -A text_editor_native_pkgs=(
    [gnome-text-editor]="gnome-text-editor"
    [kate]="kate"
    [kwrite]="kwrite"
    [mousepad]="mousepad"
    [geany]="geany"
)

declare -A text_editor_flatpak_pkgs=(
    [gnome-text-editor]="org.gnome.TextEditor"
    [kate]="org.kde.kate"
    [kwrite]="org.kde.kwrite"
    [mousepad]="org.xfce.mousepad"
    [geany]="org.geany.Geany"
)

declare -A text_editor_snap_pkgs=(
    [gnome-text-editor]="gnome-text-editor"
    [kate]="kate"
    [kwrite]="kwrite"
    [mousepad]=""
    [geany]="geany-gtk"
)

declare -A video_editor_native_pkgs=(
    [shotcut]="shotcut"
    [kdenlive]="kdenlive"
)

declare -A video_editor_flatpak_pkgs=(
    [shotcut]="org.shotcut.Shotcut"
    [kdenlive]="org.kde.kdenlive"
)

declare -A video_editor_snap_pkgs=(
    [shotcut]="shotcut"
    [kdenlive]="kdenlive"
)

declare -A torrent_client_native_pkgs=(
    [transmission-gtk]="transmission-gtk"
    [transmission-qt]="transmission-qt"
    [transmission]="transmission"
    [qbittorrent]="qbittorrent"
)

declare -A torrent_client_flatpak_pkgs=(
    [transmission-gtk]=""
    [transmission-qt]=""
    [transmission]="com.transmissionbt.Transmission"
    [qbittorrent]="org.qbittorrent.qBittorrent"
)

declare -A torrent_client_snap_pkgs=(
    [transmission-gtk]=""
    [transmission-qt]=""
    [transmission]="transmission"
    [qbittorrent]="qbittorrent-arnatious"
)

declare -A vm_application_native_pkgs=(
    [gnome-boxes]="gnome-boxes"
    [virt-manager]="virt-manager"
)

declare -A vm_application_flatpak_pkgs=(
    [gnome-boxes]="org.gnome.Boxes"
    [virt-manager]="org.virt_manager.virt-manager"
)

declare -A vm_application_snap_pkgs=(
    [gnome-boxes]="gnome-boxes"
    [virt-manager]=""
)

declare -A gpu_config_tool_native_pkgs=(
    [lact]="lact"
    [corectrl]="corectrl"
)

declare -A gpu_config_tool_flatpak_pkgs=(
    [lact]="io.github.ilya_zlobintsev.LACT"
    [corectrl]=""
)

declare -A gpu_config_tool_snap_pkgs=(
    [lact]=""
    [corectrl]=""
)

unset -v bibata_cursor_pkg
unset -v compsize_pkg
unset -v cpux_pkg
unset -v dmz_cursor_pkg
unset -v elementary_icons_pkg
unset -v greybird_theme_pkg
unset -v lact_pkg
unset -v mangohud_pkg
unset -v micro_pkg
unset -v redshift_pkg
unset -v transmission_gtk_pkg
unset -v transmission_qt_pkg
unset -v rocm_smi_pkg
unset -v steam_pkg
unset -v ubuntu_fonts_pkg
unset -v zram_pkg

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
