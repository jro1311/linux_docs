# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_install_spotify_apt() {
    if [ ! -f /etc/apt/trusted.gpg.d/spotify.gpg ]; then
        curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg \
            | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    fi

    if [ ! -f /etc/apt/sources.list.d/spotify.list ]; then
        echo "deb http://repository.spotify.com stable non-free" \
            | sudo tee /etc/apt/sources.list.d/spotify.list >/dev/null
    fi

    sudo apt-get update
    sudo apt-get install -y "spotify-client"
}

_install_spotify_pacman() {
    sudo pacman -S --needed --noconfirm spotify-launcher
}

_install_spotify_fallback() {
    if [ "$flatpak_installed" -eq 1 ]; then
        install_flatpak_pkg_bypass "com.spotify.Client"

    elif [ "$snap_installed" -eq 1 ]; then
        sudo snap install spotify
    else
        unsupported_package_manager
        return 1
    fi
}

install_spotify() {
    detect_system
    case "$primary_pm" in
        apt)    _install_spotify_apt ;;
        pacman) _install_spotify_pacman ;;
        *)      _install_spotify_fallback ;;
    esac
}

_install_codecs_apt() {
    case "$os" in
        linuxmint|ubuntu)
            sudo apt-get install -y software-properties-common
            sudo add-apt-repository multiverse
            ;;
        debian)
            enable_debian_contrib
            ;;
        *)
            case " $os_like " in
                *" ubuntu "*)
                    sudo apt-get install -y software-properties-common
                    sudo add-apt-repository multiverse
                    ;;
                *" debian "*)
                    enable_debian_contrib
                    ;;
                *)
                    unsupported_operating_system
                    return 1
                    ;;
            esac
            ;;
    esac

    case "$os" in
        linuxmint)
            sudo apt-get install -y mint-meta-codecs
            ;;
        ubuntu)
            sudo apt-get install -y ubuntu-restricted-addons ubuntu-restricted-extras
            ;;
        *)
            case " $os_like " in
                *" ubuntu "*)
                    sudo apt-get install -y ubuntu-restricted-addons ubuntu-restricted-extras
                    ;;
            esac
            ;;
    esac

    if [ "$os" = "ubuntu" ]; then
        case "$desktop" in
            kde|plasma) sudo apt-get install -y kubuntu-restricted-addons kubuntu-restricted-extras ;;
            lxqt)       sudo apt-get install -y lubuntu-restricted-addons lubuntu-restricted-extras ;;
            xfce)       sudo apt-get install -y xubuntu-restricted-addons xubuntu-restricted-extras ;;
        esac
    fi

    sudo apt-get install -y libavcodec-extra

    if [ "$optical_drive_detected" -eq 1 ]; then
        sudo apt-get install -y libdvd-pkg
    fi
}

_install_codecs_dnf() {
    case "$os" in
        openmandriva)
            sudo dnf install -y faac flac lib64dca0 lib64xvid4 x264 x265

            if [ "$optical_drive_detected" -eq 1 ]; then
                sudo dnf install -y lib64dvdcss lib64dvdnav4 lib64dvdread
            fi
            ;;
        *)
            if ! dnf repolist --enabled | grep -Fq "rpmfusion"; then
                sudo dnf install -y \
                    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
                    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

                sudo dnf -y config-manager setopt fedora-cisco-openh264.enabled=1
                sudo dnf update -y @core
                sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
                sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
                sudo dnf install -y opus pciutils

                if [ "$amd_gpu_detected" -eq 1 ]; then
                    sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
                    sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
                    sudo dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
                    sudo dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
                fi

                if [ "$intel_gpu_detected" -eq 1 ]; then
                    sudo dnf install -y intel-media-driver
                    sudo dnf install -y libva-intel-driver
                fi

                if [ "$nvidia_gpu_detected" -eq 1 ]; then
                    sudo dnf install -y libva-nvidia-driver.{i686,x86_64}
                fi

                if [ "$optical_drive_detected" -eq 1 ]; then
                    sudo dnf install -y rpmfusion-free-release-tainted
                    sudo dnf install -y libdvdcss
                fi

                sudo dnf install -y rpmfusion-nonfree-release-tainted
                sudo dnf --repo=rpmfusion-nonfree-tainted install -y "*-firmware"
            fi
            ;;
    esac
}

_install_codecs_eopkg() {
    sudo eopkg install -y aom opus x264 x265

    if [ "$optical_drive_detected" -eq 1 ]; then
        sudo eopkg install -y libdvdcss libdvdnav libdvdread
    fi
}

_install_codecs_pacman() {
    sudo pacman -S --needed --noconfirm opus mpv
}

_install_codecs_xbps() {
    sudo xbps-install -Sy faac flac opus x264 x265

    if [ "$optical_drive_detected" -eq 1 ]; then
        sudo xbps-install -y lib64dvdcss lib64dvdnav4 lib64dvdread
    fi
}

_install_codecs_zypper() {
    sudo zypper in -y opi && opi codecs
}

_install_codecs_flatpak() {
    install_flatpak_pkg_bypass "org.freedesktop.Platform.codecs-extra" "org.freedesktop.Platform.ffmpeg-full"

    if [ "$intel_gpu_detected" -eq 1 ]; then
        install_flatpak_pkg_bypass "org.freedesktop.Platform.VAAPI.Intel"
    fi
}

install_codecs() {
    detect_system
    case "$primary_pm" in
        apt)        _install_codecs_apt ;;
        dnf)        _install_codecs_dnf ;;
        eopkg)      _install_codecs_eopkg ;;
        pacman)     _install_codecs_pacman ;;
        xbps)       _install_codecs_xbps ;;
        zypper)     _install_codecs_zypper ;;
        rpm-ostree) ;;
    esac

    if [ "$flatpak_installed" -eq 1 ]; then
        _install_codecs_flatpak
    fi
}
