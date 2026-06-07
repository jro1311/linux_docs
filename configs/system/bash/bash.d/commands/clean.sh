# shellcheck shell=bash
# shellcheck disable=SC2015,SC2034,SC2154

_clean_nala() {
    local mode="${1:-manual}"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    sudo nala autoremove "${flags[@]}" || :
    sudo nala clean || :
}

_clean_apt() {
    local mode="${1:-manual}"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    sudo apt autoremove "${flags[@]}" || :
    sudo apt clean || :
}

_clean_dnf() {
    local mode="${1:-manual}"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    sudo dnf autoremove "${flags[@]}" || :
    sudo dnf clean packages || :
}

_clean_eopkg() {
    local mode="${1:-manual}"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    sudo eopkg remove-orphans "${flags[@]}" || :
    sudo eopkg delete-cache || :
}

_clean_aur() {
    local mode="${1:-manual}"
    local flags=()
    local orphans

    [ "$mode" = "auto" ] && flags+=(--noconfirm)

    orphans=$("$secondary_pm" -Qdtq 2>/dev/null || :)

    [ -z "$orphans" ] && return 0

    printf '%s\n' "$orphans" \
        | xargs -r "$secondary_pm" -Rns "${flags[@]}" || :
}

_clean_pacman() {
    local mode="${1:-manual}"
    local flags=()
    local orphans

    [ "$mode" = "auto" ] && flags+=(--noconfirm)

    orphans=$(pacman -Qdtq 2>/dev/null || :)

    [ -z "$orphans" ] && return 0

    printf '%s\n' "$orphans" \
        | sudo xargs -r pacman -Rns "${flags[@]}" || :
}

_clean_xbps() {
    local mode="${1:-manual}"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    sudo xbps-remove -Oo "${flags[@]}" || :
}

_clean_zypper() {
    local mode="${1:-manual}"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    sudo zypper purge-kernels "${flags[@]}" || :
    sudo zypper clean || :
}

_clean_rpm_ostree() {
    local mode="${1:-manual}"

    if [ "$mode" = "manual" ]; then
        confirm "Confirm cleanup operation [y/N]" && sudo rpm-ostree cleanup -bm || :
    else
        sudo rpm-ostree cleanup -bm || :
    fi
}

_clean_toolbox() {
    local mode="${1:-manual}"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    toolbox run sudo dnf autoremove "${flags[@]}" || :
    toolbox run sudo dnf clean packages || :
}

_clean_flatpak() {
    local mode="${1:-manual}"
    local flags=()

    [ "$mode" = "auto" ] && flags+=(-y)

    flatpak uninstall --unused "${flags[@]}" || :
}

clean_sm() {
    local mode="${1:-manual}"

    case "$secondary_pm" in
        "nala")
            announce_clean "$secondary_pm"
            _clean_nala "$mode"
            ;;
        paru|yay)
            announce_clean "$secondary_pm"
            _clean_aur_helper "$mode"
            ;;
    esac
}

clean_pm() {
    local mode="${1:-manual}"

    case "$primary_pm" in
        apt)
            announce_clean "$primary_pm"
            _clean_apt "$mode"
            ;;
        dnf)
            announce_clean "$primary_pm"
            _clean_dnf "$mode"
            ;;
        eopkg)
            announce_clean "$primary_pm"
            _clean_eopkg "$mode"
            ;;
        pacman)
            announce_clean "$primary_pm"
            _clean_pacman "$mode"
            ;;
        xbps)
            announce_clean "$primary_pm"
            _clean_xbps "$mode"
            ;;
        zypper)
            announce_clean "$primary_pm"
            _clean_zypper "$mode"
            ;;
        rpm-ostree)
            announce_clean "$primary_pm"
            _clean_rpm_ostree "$mode"
            ;;
    esac
}

clean_optionals() {
    local mode="${1:-manual}"
    local option
    local -a optionals=(
        toolbox
        flatpak
        snap
    )

    for option in "${optionals[@]}"; do
        case "$option" in
            toolbox)
                if [ "$toolbox_installed" -eq 1 ]; then
                    announce_clean "$option"
                    _clean_toolbox "$mode"
                fi
                ;;
            flatpak)
                if [ "$flatpak_installed" -eq 1 ]; then
                    announce_clean "$option"
                    _clean_flatpak "$mode"
                fi
                ;;
            snap)
                if [ "$snap_installed" -eq 1 ]; then
                    no_function_available "snap"
                fi
                ;;
        esac
    done
}

clean() {
    local mode="${1:-manual}"
    detect_system

    case "$primary_pm" in
        rpm-ostree)
            clean_optionals "$mode"
            clean_pm "$mode"
            ;;
        *)
            if [ -n "$secondary_pm" ]; then
                clean_sm "$mode"
            else
                clean_pm "$mode"
            fi

            clean_optionals "$mode"
            ;;
    esac
}
