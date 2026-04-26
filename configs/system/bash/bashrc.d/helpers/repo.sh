# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

enable_chaotic_aur() {
    detect_system
    case "$primary_pm" in
        "pacman")
            if ! grep -Fq "chaotic" /etc/pacman.conf; then
                sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com || return 1
                sudo pacman-key --lsign-key 3056513887B78AEB || return 1
                sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' || return 1
                sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' || return 1
                sudo tee -a /etc/pacman.conf <<-'EOF' || return 1
[chaotic-aur]
    Include = /etc/pacman.d/chaotic-mirrorlist
EOF
            fi
            ;;
        *)
            unsupported_package_manager
            return 1
            ;;
    esac
}

enable_debian_contrib() {
    detect_system
    case "$os" in
        ubuntu)
            unsupported_operating_system
            return 1
            ;;
        debian)
            sudo apt modernize-sources -y || return 1

            if ! grep -Fq "contrib" /etc/apt/sources.list.d/debian.sources; then
                sudo sed -i '/Components:/ s/$/ contrib/' /etc/apt/sources.list.d/debian.sources || return 1
                sudo apt-get update || return 1
            fi
            ;;
        *)
            case " $os_like " in
                *" ubuntu "*)
                    unsupported_operating_system
                    return 1
                    ;;
                *" debian "*)
                    sudo apt modernize-sources -y || return 1

                    if ! grep -Fq "contrib" /etc/apt/sources.list.d/debian.sources; then
                        sudo sed -i '/Components:/ s/$/ contrib/' /etc/apt/sources.list.d/debian.sources || return 1
                        sudo apt-get update || return 1
                    fi
                    ;;
                *)
                    unsupported_operating_system
                    return 1
            esac
        ;;
    esac
}

enable_debian_backports() {
    detect_system
    case "$os" in
        ubuntu)
            unsupported_operating_system
            return 1
            ;;
        debian)
            sudo apt modernize-sources -y || return 1

            if ! [ -f /etc/apt/sources.list.d/debian_backports.sources ]; then
                sudo cp "$HOME/Documents/linux_docs/configs/system/debian_backports.sources" /etc/apt/sources.list.d/ || return 1
                sudo sed -i "/Suites:/ s/version-backports/$(lsb_release -cs)-backports/" /etc/apt/sources.list.d/debian_backports.sources || return 1
                sudo apt-get update || return 1
            fi
            ;;
        *)
            case " $os_like " in
                *" ubuntu "*)
                    unsupported_operating_system
                    return 1
                    ;;
                *" debian "*)
                    sudo apt modernize-sources -y || return 1

                    if [ ! -f /etc/apt/sources.list.d/debian_backports.sources ]; then
                        sudo cp "$HOME/Documents/linux_docs/configs/system/debian_backports.sources" /etc/apt/sources.list.d/ || return 1
                        sudo sed -i "/Suites:/ s/version-backports/$(lsb_release -cs)-backports/" /etc/apt/sources.list.d/debian_backports.sources || return 1
                        sudo apt-get update || return 1
                    fi
                    ;;
                *)
                    unsupported_operating_system
                    return 1
            esac
        ;;
    esac
}
