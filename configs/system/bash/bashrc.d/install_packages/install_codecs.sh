install_codecs_apt() {
    case "$os" in
        "debian")
            enable_debian_contrib
            ;;
        "linuxmint")
            sudo apt-get install -y software-properties-common
            sudo add-apt-repository multiverse
            sudo apt-get install -y mint-meta-codecs
            ;;
        "ubuntu")
            sudo apt-get install -y software-properties-common
            sudo add-apt-repository multiverse
            sudo apt-get install -y ubuntu-restricted-addons ubuntu-restricted-extras
            ;;
        *)
            case "$os_like" in
                "debian")
                    enable_debian_contrib
                    ;;
                "ubuntu"|"ubuntu debian")
                    sudo apt-get install -y software-properties-common
                    sudo add-apt-repository multiverse
                    sudo apt-get install -y ubuntu-restricted-addons ubuntu-restricted-extras
                    ;;
                *)
                    unsupported_operating_system
                    return 1
                    ;;
            esac
            ;;
    esac

    if [ "$os" = "ubuntu" ]; then
        case "$desktop" in
            "kde"|"plasma")
                sudo apt-get install -y kubuntu-restricted-addons kubuntu-restricted-extras
                ;;
            "lxqt")
                sudo apt-get install -y lubuntu-restricted-addons lubuntu-restricted-extras
                ;;
            "xfce")
                sudo apt-get install -y xubuntu-restricted-addons xubuntu-restricted-extras
                ;;
        esac
    fi

    sudo apt-get install -y libavcodec-extra

    if [ -e /dev/sr0 ]; then
        green_message "Optical drive detected."
        sudo apt-get install -y libdvd-pkg
    else
        yellow_message "No optical drive detected."
    fi
}

install_codecs_dnf() {
    if [ "$os" = "openmandriva" ]; then
        sudo dnf install -y faac flac lib64dca0 lib64xvid4 x264 x265

        if [ -e /dev/sr0 ]; then
            green_message "Optical drive detected."
            sudo dnf install -y lib64dvdcss lib64dvdnav4 lib64dvdread
        else
            yellow_message "No optical drive detected."
        fi

    else

        sudo dnf install -y \
            "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
            "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

        sudo dnf -y config-manager setopt fedora-cisco-openh264.enabled=1
        sudo dnf update -y @core
        sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
        sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
        sudo dnf install -y opus pciutils

        gpu_info=$(lspci | grep -E "VGA|3D")

        if echo "$gpu_info" | grep -iq "amd"; then
            green_message "Detected GPU:" "AMD"
            sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
            sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
            sudo dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
            sudo dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
        fi

        if echo "$gpu_info" | grep -iq "intel"; then
            green_message "Detected GPU:" "Intel"
            sudo dnf install -y intel-media-driver
            sudo dnf install libva-intel-driver
        fi

        if echo "$gpu_info" | grep -iq "nvidia"; then
            green_message "Detected GPU:" "Nvidia"
            sudo dnf install -y libva-nvidia-driver.{i686,x86_64}
        fi

        if [ -e /dev/sr0 ]; then
            green_message "Optical drive detected."
            sudo dnf install -y rpmfusion-free-release-tainted
            sudo dnf install -y libdvdcss
        fi

        sudo dnf install -y rpmfusion-nonfree-release-tainted
        sudo dnf --repo=rpmfusion-nonfree-tainted install -y "*-firmware"

    fi
}

install_codecs_eopkg() {
    sudo eopkg install -y aom opus x264 x265

    if [ -e /dev/sr0 ]; then
        green_message "Optical drive detected."
        sudo eopkg install -y libdvdcss libdvdnav libdvdread
    else
        yellow_message "No optical drive detected."
    fi
}

install_codecs_pacman() {
    sudo pacman -S --needed --noconfirm opus mpv
}

install_codecs_xbps() {
    sudo xbps-install -Sy faac flac opus x264 x265

    if [ -e /dev/sr0 ]; then
        green_message "Optical drive detected."
        sudo xbps-install -y lib64dvdcss lib64dvdnav4 lib64dvdread
    fi
}

install_codecs_zypper() {
    sudo zypper in -y opi && opi codecs
}

install_codecs_flatpak() {
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    flatpak install flathub -y org.freedesktop.Platform.codecs-extra org.freedesktop.Platform.ffmpeg-full

    if echo "$gpu_info" | grep -Fiq "intel"; then
        green_message "Detected GPU:" "Intel"
        flatpak install flathub -y org.freedesktop.Platform.VAAPI.Intel
    else
        yellow_message "No Intel GPU detected."
    fi
}

install_codecs() {
    case "$primary_package_manager" in
        "apt")
            install_codecs_apt
            ;;
        "dnf")
            install_codecs_dnf
            ;;
        "eopkg")
            install_codecs_eopkg
            ;;
        "pacman")
            install_codecs_pacman
            ;;
        "xbps")
            install_codecs_xbps
            ;;
        "zypper")
            install_codecs_zypper
            ;;
        "rpm-ostree")
            echo "Nothing to do."
            return 0
            ;;
        *)
            unsupported_package_manager
            return 1
            ;;
    esac

    if [ "$flatpak_installed" -eq 1 ]; then
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        install_codecs_flatpak
    else
        install_flatpak && flatpak_installed=1
        install_codecs_flatpak
    fi

    green_message "Multimedia codecs are now installed."
}
