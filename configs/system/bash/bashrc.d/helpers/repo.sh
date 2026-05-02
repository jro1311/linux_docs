# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

backup_dir() {
    assert_arity "$#" "eq" 1 "<directory>" || return 1

    local dir="$1"
    local base="${dir}_old"

    [ -d "$dir" ] || return 0

    local candidate="$base"
    local count=1

    while [ -d "$candidate" ]; do
        candidate="${base}${count}"
        count=$((count + 1))
    done

    mv "$dir" "$candidate" || {
        red_message "Error:" "Failed to move '$dir'."
        return 1
    }
}

cleanup_old_backups() {
    assert_arity "$#" "eq" 1 "<directory>" || return 1

    local dir="$1"
    local base="${dir}_old"

    case $PWD in
        "$dir"*)
            yellow_message "Skipped:" "Inside '$dir', cleanup not performed."
            return 0
            ;;
    esac

    set -- "$base" "$base"*

    case $2 in
        "$base"*) rm -rf "$@" ;;
        *) return 0 ;;
    esac
}

enable_chaotic_aur() {
    detect_system
    case "$primary_pm" in
        "pacman")
            if ! grep -Fq "chaotic" /etc/pacman.conf; then
                sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com || return 1
                sudo pacman-key --lsign-key 3056513887B78AEB || return 1
                sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' || return 1
                sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' || return 1
                sudo tee -a /etc/pacman.conf >/dev/null <<-'EOF' || return 1
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
        devuan)
            sudo apt modernize-sources -y || return 1

            if ! grep -Fq "contrib" /etc/apt/sources.list.d/devuan.sources; then
                sudo sed -i '/Components:/ s/$/ contrib/' /etc/apt/sources.list.d/devuan.sources || return 1
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
        devuan)
            sudo apt modernize-sources -y || return 1

            if ! [ -f /etc/apt/sources.list.d/devuan_backports.sources ]; then
                sudo cp "$HOME/Documents/linux_docs/configs/system/devuan_backports.sources" /etc/apt/sources.list.d/ || return 1
                sudo sed -i "/Suites:/ s/version-backports/$(lsb_release -cs)-backports/" /etc/apt/sources.list.d/devuan_backports.sources || return 1
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
