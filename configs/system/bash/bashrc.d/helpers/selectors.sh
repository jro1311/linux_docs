# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

select_git_repo() {
    green_message "GitHub Repositories:"
    printf '%s\n' \
        "[1] linux_docs" \
        "[2] custom" \
        "[x] cancel" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select repo [1-2]: " num

        case "$num" in
            1) printf '%s' "linux_docs"; return 0 ;;
            2) printf '%s' "custom"; return 0 ;;
            x) return 0 ;;
            *) continue ;;
        esac
    done
}

exclude_flatpaks() {
    while true; do
        if [ "${#flatpaks[@]}" -eq 0 ]; then
            printf '%s' ""
            break
        fi

        green_message "Flatpaks:"

        i=1
        menu=""

        for fp in "${flatpaks[@]}"; do
            printf -v menu '%s[%d] %s\n' "$menu" "$i" "$fp"
            i=$((i+1))
        done

        printf -v menu '%s[x] none' "$menu"
        printf '%s\n' "$menu" | sed 's/^/  /' >&2

        read -r -p "Exclude a Flatpak from installation? [1-$((i-1)) or x]: " num

        case "$num" in
            [Xx]) break ;;
            ''|*[!0-9]*) continue ;;
        esac

        if [ "$num" -lt 1 ] || [ "$num" -gt "${#flatpaks[@]}" ]; then
            continue
        fi

        unset 'flatpaks[num-1]'
        flatpaks=("${flatpaks[@]}")
    done
}

select_firefox_browser() {
    green_message "Firefox Browsers:"
    printf '%s\n' \
        "[1] Firefox" \
        "[2] Floorp" \
        "[3] LibreWolf" \
        "[4] Tor" \
        "[5] Waterfox" \
        "[6] Zen" \
        "[x] none" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select a Firefox-based browser [1-6]: " num

        case "$num" in
            1) printf '%s|%s' "firefox" "Firefox" ;;
            2) printf '%s|%s' "floorp" "Floorp" ;;
            3) printf '%s|%s' "librewolf" "LibreWolf" ;;
            4) printf '%s|%s' "waterfox" "Waterfox" ;;
            5) printf '%s|%s' "zen" "Zen" ;;
            x) ;;
            *) continue ;;
        esac

        break
    done
}

select_chromium_browser() {
    green_message "Chromium Browsers:"
    printf '%s\n' \
        "[1] Brave" \
        "[2] Chrome" \
        "[3] Chromium" \
        "[4] Opera" \
        "[5] Opera GX" \
        "[6] Ungoogled Chromium" \
        "[7] Vivaldi" \
        "[x] none" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select a Chromium-based browser [1-7]: " num

        case "$num" in
            1) printf '%s|%s' "brave" "Brave" ;;
            2) printf '%s|%s' "chrome" "Chrome" ;;
            3) printf '%s|%s' "chromium" "Chromium" ;;
            4) printf '%s|%s' "opera" "Opera" ;;
            5) printf '%s|%s' "opera gx" "Opera GX" ;;
            6) printf '%s|%s' "ungoogled chromium" "Ungoogled Chromium";;
            7) printf '%s|%s' "vivaldi" "Vivaldi";;
            x) ;;
            *) continue ;;
        esac

        break
    done
}

select_office_suite() {
    green_message "Office Suites:"
    printf '%s\n' \
        "[1] LibreOffice" \
        "[2] OnlyOffice" \
        "[x] none" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select an office suite [1-2]: " num

        case "$num" in
            1) printf '%s|%s' "libreoffice" "LibreOffice" ;;
            2) printf '%s|%s' "onlyoffice" "OnlyOffice" ;;
            x) printf '%s|%s' "" "" ;;
            *) continue ;;
        esac

        break
    done
}

select_torrent_client() {
    green_message "Torrent Clients:"
    printf '%s\n' \
        "[1] qBittorrent" \
        "[2] Transmission" \
        "[x] none" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select a torrent client [1-2]: " num

        case "$num" in
            1) printf '%s|%s' "qbittorrent" "qBittorrent" ;;
            2) printf '%s|%s' "transmission" "Transmission" ;;
            x) printf '%s|%s' "" "" ;;
            *) continue ;;
        esac

        break
    done
}

select_vm_application() {
    green_message "Virtual Machine Application:"
    printf '%s\n' \
        "[1] GNOME Boxes" \
        "[2] Virt-Manager" \
        "[x] none" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select a virtual machine application [1-2]: " num

        case "$num" in
            1) printf '%s|%s' "gnome-boxes" "GNOME Boxes" ;;
            2) printf '%s|%s' "virt-manager" "Virt-Manager" ;;
            x) printf '%s|%s' "" "" ;;
            *) continue ;;
        esac

        break
    done
}

select_gpu_config_tool() {
    green_message "GPU Configuration Tools:"
    printf '%s\n' \
        "[1] LACT" \
        "[2] CoreCtrl" \
        "[x] none" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select tool [1-2]: " num

        case "$num" in
            1) printf '%s|%s' "lact" "LACT" ;;
            2) printf '%s|%s' "corectrl" "CoreCtrl" ;;
            x) ;;
            *) continue ;;
        esac

        break
    done
}

select_indentation_format() {
    green_message "Formats:"
    printf '%s\n' \
        "[1] Tabs" \
        "[2] Spaces" \
        "[x] cancel" \
        | sed "s/^/  /" >&2

    while true; do
        read -r -p "Select format to convert to [1-2]: " num

        case "$num" in
            1) printf '%s|%s\n' "tabs" "unexpand" ;;
            2) printf '%s|%s\n' "spaces" "expand" ;;
            x) printf '%s|%s\n' "" "" ;;
            *) continue ;;
        esac

        break
    done
}
