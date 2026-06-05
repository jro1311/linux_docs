# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

_clean_pm_bypass() {
    announce_clean "$primary_pm"

    case "$primary_pm" in
        apt)
            sudo apt-get autoremove --purge -y  >/dev/null || :
            sudo apt-get clean                  >/dev/null || :
            ;;
        dnf)
            sudo dnf autoremove -y  >/dev/null || :
            sudo dnf clean packages >/dev/null || :
            ;;
        eopkg)
            sudo eopkg remove-orphans -y    >/dev/null || :
            sudo eopkg delete-cache         >/dev/null || :
            ;;
        pacman)
            local orphans
            orphans=$(pacman -Qdtq 2>/dev/null || :)

            if [ -n "$orphans" ]; then
                printf '%s\n' "$orphans" \
                    | sudo xargs -r pacman -Rns --noconfirm >/dev/null || :
            fi
            ;;
        xbps)
            sudo xbps-remove -Ooy >/dev/null || :
            ;;
        zypper)
            sudo zypper purge-kernels -y    >/dev/null || :
            sudo zypper clean               >/dev/null || :
            ;;
        rpm-ostree)
            sudo rpm-ostree cleanup -bm >/dev/null || :
            ;;
    esac
}

_clean_aur_bypass() {
    [ "$primary_pm" != "pacman" ] && return 0
    [ -z "$secondary_pm" ] && return 0

    announce_clean "$secondary_pm"

    local orphans
    orphans=$("$secondary_pm" -Qdtq 2>/dev/null || :)

    if [ -n "$orphans" ]; then
        printf '%s\n' "$orphans" \
            | xargs -r "$secondary_pm" -Rns --noconfirm >/dev/null || :
    fi
}

_clean_toolbox_bypass() {
    [ "$toolbox_installed" -eq 0 ] && return 0

    announce_clean "toolbox"
    toolbox run sudo sh -c 'dnf autoremove -y; dnf clean packages' >/dev/null || :
}

_clean_flatpak_bypass() {
    [ "$flatpak_installed" -eq 0 ] && return 0

    announce_clean "flatpak"
    flatpak uninstall --unused -y >/dev/null || :
}

_clean_optionals_bypass() {
    _clean_toolbox_bypass
    _clean_flatpak
}

clean_bypass() {
    detect_system

    _clean_pm_bypass
    _clean_aur_bypass
    _clean_optionals_bypass
}
