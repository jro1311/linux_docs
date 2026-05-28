# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_install_spotify_apt() {
    if [ ! -f /etc/apt/trusted.gpg.d/spotify.gpg ]; then
        curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg \
            | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg || return 1
    fi

    if [ ! -f /etc/apt/sources.list.d/spotify.list ]; then
        echo "deb http://repository.spotify.com stable non-free" \
            | sudo tee /etc/apt/sources.list.d/spotify.list >/dev/null || return 1
    fi

    sudo apt-get update || return 1
    sudo apt-get install -y "spotify-client" || return 1
}

_install_spotify_pacman() {
    sudo pacman -S --needed --noconfirm spotify-launcher || return 1
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
            sudo apt-get install -y software-properties-common || return 1
            sudo add-apt-repository multiverse || return 1
            ;;
        debian)
            enable_debian_contrib || return 1
            ;;
        *)
            case " $os_like " in
                *" ubuntu "*)
                    sudo apt-get install -y software-properties-common || return 1
                    sudo add-apt-repository multiverse || return 1
                    ;;
                *" debian "*)
                    enable_debian_contrib || return 1
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
            sudo apt-get install -y mint-meta-codecs || return 1
            ;;
        ubuntu)
            sudo apt-get install -y ubuntu-restricted-addons ubuntu-restricted-extras || return 1
            ;;
        *)
            case " $os_like " in
                *" ubuntu "*)
                    sudo apt-get install -y ubuntu-restricted-addons ubuntu-restricted-extras || return 1
                    ;;
            esac
            ;;
    esac

    if [ "$os" = "ubuntu" ]; then
        case "$desktop" in
            kde|plasma) sudo apt-get install -y kubuntu-restricted-addons kubuntu-restricted-extras || return 1 ;;
            lxqt)       sudo apt-get install -y lubuntu-restricted-addons lubuntu-restricted-extras || return 1 ;;
            xfce)       sudo apt-get install -y xubuntu-restricted-addons xubuntu-restricted-extras || return 1 ;;
        esac
    fi

    sudo apt-get install -y libavcodec-extra || return 1

    if [ "$optical_drive_detected" -eq 1 ]; then
        sudo apt-get install -y libdvd-pkg || return 1
    fi
}

_install_codecs_dnf() {
    case "$os" in
        openmandriva)
            sudo dnf install -y faac flac lib64dca0 lib64xvid4 x264 x265 || return 1

            if [ "$optical_drive_detected" -eq 1 ]; then
                sudo dnf install -y lib64dvdcss lib64dvdnav4 lib64dvdread || return 1
            fi
            ;;
        *)
            if ! dnf repolist --enabled 2>/dev/null | grep -Fq "rpmfusion"; then
                sudo dnf install -y \
                    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
                    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" \
                    || return 1

                sudo dnf -y config-manager setopt fedora-cisco-openh264.enabled=1 || return 1
                sudo dnf update -y @core || return 1
                sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing || return 1
                sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin || return 1
                sudo dnf install -y opus pciutils || return 1

                if [ "$amd_gpu_detected" -eq 1 ]; then
                    sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld || return 1
                    sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld || return 1
                    sudo dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686 || return 1
                    sudo dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686 || return 1
                fi

                if [ "$intel_gpu_detected" -eq 1 ]; then
                    sudo dnf install -y intel-media-driver || return 1
                    sudo dnf install -y libva-intel-driver || return 1
                fi

                if [ "$nvidia_gpu_detected" -eq 1 ]; then
                    sudo dnf install -y libva-nvidia-driver.{i686,x86_64} || return 1
                fi

                if [ "$optical_drive_detected" -eq 1 ]; then
                    sudo dnf install -y rpmfusion-free-release-tainted || return 1
                    sudo dnf install -y libdvdcss || return 1
                fi

                sudo dnf install -y rpmfusion-nonfree-release-tainted || return 1
                sudo dnf --repo=rpmfusion-nonfree-tainted install -y "*-firmware" || return 1
            fi
            ;;
    esac
}

_install_codecs_eopkg() {
    sudo eopkg install -y aom opus x264 x265 || return 1

    if [ "$optical_drive_detected" -eq 1 ]; then
        sudo eopkg install -y libdvdcss libdvdnav libdvdread || return 1
    fi
}

_install_codecs_pacman() {
    sudo pacman -S --needed --noconfirm opus mpv || return 1
}

_install_codecs_xbps() {
    sudo xbps-install -Sy faac flac opus x264 x265 || return 1

    if [ "$optical_drive_detected" -eq 1 ]; then
        sudo xbps-install -y lib64dvdcss lib64dvdnav4 lib64dvdread || return 1
    fi
}

_install_codecs_zypper() {
    sudo zypper in -y opi || return 1
    opi codecs || return 1
}

_install_codecs_flatpak() {
    install_flatpak_pkg_bypass "org.freedesktop.Platform.codecs-extra" "org.freedesktop.Platform.ffmpeg-full" || return 1

    if [ "$intel_gpu_detected" -eq 1 ]; then
        install_flatpak_pkg_bypass "org.freedesktop.Platform.VAAPI.Intel" || return 1
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
