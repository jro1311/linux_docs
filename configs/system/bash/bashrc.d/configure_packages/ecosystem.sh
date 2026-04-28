# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

configure_distrobox() {
    detect_system
    case "$os" in
        arch)
            distrobox-create "$os" -i arch:latest
            ;;
        debian)
            distrobox-create "$os" -i debian:latest
            ;;
        fedora)
            distrobox-create "$os" -i fedora:latest
            ;;
        opensuse)
            distrobox-create "$os" -i opensuse:latest
            ;;
        ubuntu)
            distrobox-create "$os" -i ubuntu:latest
            ;;
        *)
            case " $os_like " in
                *" ubuntu "*)
                    distrobox-create "$os" -i ubuntu:latest
                    ;;
                *" debian "*)
                    distrobox-create "$os" -i debian:latest
                    ;;
                *" fedora "*)
                    distrobox-create "$os" -i fedora:latest
                    ;;
                *)
                    distrobox-create arch -i arch:latest
                    ;;
            esac
    esac
}

configure_toolbox() {
    detect_system
    case $os in
        fedora)
            toolbox create --distro fedora --release "$VERSION_ID"
            ;;
        *)
            unsupported_operating_system
            return 1
            ;;
    esac
}

configure_flatpak() {
    if flatpak remote-list | grep -Fq "fedora"; then
        flatpak remote-modify --disable fedora
    fi

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

configure_snap() {
    detect_system
    if [ "$init_system" != "systemd" ]; then
        unsupported_init_system
        return 1
    fi

    sudo systemctl unmask \
        snapd.socket \
        snapd.service \
        snapd.seeded.service

    sudo systemctl enable --now \
        snapd.socket \
        snapd.service \
        snapd.seeded.service

    # Enables classic snap support
    if [ ! -e /snap ]; then
        sudo ln -s /var/lib/snapd/snap /snap
    fi

    sudo snap install snapd
    sudo snap install snap-store
}

configure_waydroid() {
    detect_system
    case "$primary_pm" in
        dnf)
            echo "System OTA: https://ota.waydro.id/system"
            echo "Vendor OTA: https://ota.waydro.id/vendor"
            ;;
    esac

    sudo waydroid init
    enable_service "waydroid-container"
}
