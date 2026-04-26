#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# shellcheck disable=SC2044
# Sources all .sh files in bashrc.d
for rc in $(find "$HOME/Documents/linux_docs/configs/system/bash/bashrc.d" -type f -name '*.sh' 2>/dev/null); do
    . "$rc"
done

detect_system
print_system_info

ld_prefix="$HOME/Documents/linux_docs/scripts"

if [ "$swapfile_exists" -eq 1 ] && confirm "Remove swapfile? [y/N]"; then
    run_script "$ld_prefix/remove_swapfile.sh" && swapfile_exists=0
fi

if [ "$swapfile_exists" -eq 1 ] || [ "$swap_partition_exists" -eq 1 ]; then
    enable_zswap
fi

firefox_browser=""
chromium_browser=""
torrent_client=""
torrent_client_uc=""

green_message "Firefox Browsers:"
printf '%s\n' \
    "[1] Firefox" \
    "[2] Floorp" \
    "[3] LibreWolf" \
    "[4] Tor" \
    "[5] Waterfox" \
    "[6] Zen" \
    "[x] none" | sed "s/^/  /"

while true; do
    read -r -p "Select a Firefox-based browser [1-6]: " num

    case "$num" in
        1) firefox_browser="firefox" ;;
        2) firefox_browser="floorp" ;;
        3) firefox_browser="librewolf" ;;
        4) firefox_browser="waterfox" ;;
        5) firefox_browser="zen" ;;
        x) ;;
        *) continue ;;
    esac

    firefox_browser_uc=$(printf '%s' "$firefox_browser" | sed 's/\b\(.\)/\u\1/g')
    break
done

green_message "Chromium Browsers:"
printf '%s\n' \
    "[1] Brave" \
    "[2] Chrome" \
    "[3] Chromium" \
    "[4] Opera" \
    "[5] Opera GX" \
    "[6] Ungoogled Chromium" \
    "[7] Vivaldi" \
    "[x] none" | sed "s/^/  /"

while true; do
    read -r -p "Select a Chromium-based browser [1-7]: " num

    case "$num" in
        1) chromium_browser="brave" ;;
        2) chromium_browser="chrome" ;;
        3) chromium_browser="chromium" ;;
        4) chromium_browser="opera" ;;
        5) chromium_browser="opera gx" ;;
        6) chromium_browser="ungoogled chromium" ;;
        7) chromium_browser="vivaldi" ;;
        x) ;;
        *) continue ;;
    esac

    chromium_browser_uc=$(printf '%s' "$chromium_browser" | sed 's/\b\(.\)/\u\1/g')
    break
done

green_message "Torrent Clients:"
printf '%s\n' \
    "[1] qBittorrent" \
    "[2] Transmission" \
    "[x] none" | sed "s/^/  /"

while true; do
    read -r -p "Select a torrent client [1-2]: " num

    case "$num" in
        1)
            torrent_client="qbittorrent"
            torrent_client_uc="qBittorrent"
            ;;
        2)
            torrent_client="transmission"
            torrent_client_uc="Transmission"
            ;;
        x) ;;
        *) continue ;;
    esac

    break
done

print_field "Firefox Browser" "$firefox_browser_uc"
print_field "Chromium Browser" "$chromium_browser_uc"
print_field "Torrent Client" "$torrent_client_uc"

install_zram=0
install_codecs=0
install_redshift=0
install_gaming_pkgs=0

declare -A prompts=(
    [install_zram]="Install zram? [y/N]"
    [install_codecs]="Install codecs? [y/N]"
    [install_redshift]="Install redshift? [y/N]"
    [install_gaming_pkgs]="Install gaming packages? [y/N]"
)

ordered_prompt_vars=(
    install_zram
    install_codecs
    install_redshift
    install_gaming_pkgs
)

for var in "${ordered_prompt_vars[@]}"; do
    if confirm "${prompts[$var]}"; then
        printf -v "$var" '%s' 1
    fi
done

for var in "${!prompts[@]}"; do
    if [ "${!var}" -eq 1 ]; then
        optional_pkg=${var#install_}
        optional_pkg=${optional_pkg//_/ }
        print_field "Queued Install" "$optional_pkg"
    fi
done

confirm_proceed

ensure_wheel_membership
apply_btrfs_cow_policies
remove_default_pkgs
clean "auto"
upgrade "auto"

case "$os" in
    ubuntu)
        ;;
    pacman)
        enable_chaotic_aur
        ;;
    debian)
        enable_debian_contrib
        enable_debian_backports
        ;;
    *)
        case " $os_like " in
            *" ubuntu "*)
                ;;
            *" debian "*)
                enable_debian_contrib
                enable_debian_backports
                ;;
        esac
    ;;
esac

if [ "$primary_pm" != "rpm-ostree" ]; then
    install_pm_pkg_bypass "${universal_pkgs[@]}"
fi

case "$primary_pm" in
    apt)
        install_pm_pkg_bypass "${debian_pkgs[@]}" && flatpak_installed=1
        ;;
    dnf)
        case "$os" in
            openmandriva)
                install_pm_pkg_bypass "${openmandriva_pkgs[@]}" && flatpak_installed=1
                ;;
            *)
                install_pm_pkg_bypass "${fedora_pkgs[@]}" && flatpak_installed=1
                ;;
        esac
        ;;
    eopkg)
        install_pm_pkg_bypass "${solus_pkgs[@]}" && flatpak_installed=1
        ;;
    pacman)
        install_pm_pkg_bypass "${arch_pkgs[@]}" && flatpak_installed=1
        install_aur_pkg_bypass "${aur_pkgs[@]}"
        ;;
    xbps)
        install_pm_pkg_bypass "${void_pkgs[@]}" && flatpak_installed=1
        ;;
    zypper)
        install_pm_pkg_bypass "${opensuse_pkgs[@]}" && flatpak_installed=1
        ;;
    rpm-ostree)
        install_pm_pkg_bypass "${atomic_pkgs[@]}"
        ;;
    *)
        unsupported_package_manager
        exit 1
        ;;
esac

if [ "$primary_pm" != "rpm-ostree" ]; then
    install_pm_pkg_bypass "${micro_pkg[$primary_pm]}"
    install_pm_pkg_bypass "${rocm_smi_pkg[$primary_pm]}"
fi

case "$os" in
    fedora)
        if [ "$toolbox_installed" -eq -1 ]; then
            if ! toolbox list | grep -Fq "fedora-toolbox-$VERSION_ID"; then
                toolbox create --distro fedora --release "$VERSION_ID"
            fi

            toolbox run sudo dnf upgrade -y
            toolbox run sudo dnf install -y "${toolbox_pkgs[@]}"
        fi
        ;;
esac

if ! grep -Fq "deno.bash" "$HOME/.bashrc"; then
    curl -fsSL https://deno.land/install.sh | sh
fi

install_fonts_microsoft

[ "$install_zram" -eq 1 ] && install_zram
[ "$install_codecs" -eq 1 ] && install_codecs
[ "$install_redshift" -eq 1 ] && install_pm_pkg_bypass "${redshift_pkg[$primary_pm]}"

ensure_pkg "flatpak" && flatpak_installed=1

if [ "$flatpak_installed" -eq 1 ]; then
    configure_flatpak

    case "$firefox_browser" in
        firefox)    install_flatpak_pkg_bypass "org.mozilla.firefox" ;;
        floorp)     install_flatpak_pkg_bypass "one.ablaze.floorp" ;;
        librewolf)  install_flatpak_pkg_bypass "io.gitlab.librewolf-community" ;;
        tor)        install_flatpak_pkg_bypass "org.torproject.torbrowser-launcher" ;;
        waterfox)   install_flatpak_pkg_bypass "net.waterfox.waterfox" ;;
        zen)        install_flatpak_pkg_bypass "app.zen_browser.zen" ;;
    esac

    case "$chromium_browser" in
        brave)
            case "$primary_pm" in
                rpm-ostree|xbps)
                    install_flatpak_pkg_bypass "com.brave.Browser"
                    ;;
                *)
                    if ! command -v brave-browser >/dev/null 2>&1; then
                        curl -fsS https://dl.brave.com/install.sh | sh
                    fi
                    ;;
            esac
            ;;
        chrome)                 install_flatpak_pkg_bypass "com.google.Chrome" ;;
        chromium)               install_flatpak_pkg_bypass "org.chromium.Chromium" ;;
        opera)                  install_flatpak_pkg_bypass "com.opera.Opera" ;;
        "opera gx")             install_flatpak_pkg_bypass "com.opera.opera-gx" ;;
        "ungoogled chromium")   install_flatpak_pkg_bypass "io.github.ungoogled_software.ungoogled_chromium" ;;
        vivaldi)                install_flatpak_pkg_bypass "com.vivaldi.Vivaldi" ;;
    esac

    case "$primary_pm" in
        rpm-ostree)
            install_flatpak_pkg_bypass "${atomic_flatpaks[@]}"
            ;;
    esac

    install_flatpak_pkg_bypass "${flatpaks[@]}"
fi

case "$torrent_client" in
    qbittorrent)
        case "$primary_pm" in
            rpm-ostree)
                if install_flatpak_pkg_bypass "org.qbittorrent.qBittorrent"; then
                    configure_qbittorrent
                fi
                ;;
            *)
                if install_pm_pkg_bypass "qbittorrent"; then
                    configure_qbittorrent
                fi
                ;;
        esac
        ;;
    transmission)
        if install_transmission; then
            configure_transmission
        fi
        ;;
esac

if [ "$btrfs_detected" -eq 1 ]; then
    install_pm_pkg_bypass "${compsize_pkg[$primary_pm]}"

    case "$init_system" in
        systemd)
            if install_pm_pkg_bypass "btrfsmaintenance"; then
                configure_btrfsmaintenance
            fi
            ;;
    esac
fi

setup_desktop

[ "$install_gaming_pkgs" -eq 1 ] && run_script "$ld_prefix/setup_gaming.sh"

if [ "$battery_detected" -eq 1 ]; then
    add_kernel_parameter "preempt=lazy"
else
    add_kernel_parameter "preempt=full"
fi

add_firewall_exceptions
enable_permanent_mac_address
apply_pm_config

run_script "$ld_prefix/copy_pkg_configs.sh"
run_script "$ld_prefix/sync_bashrc_configs.sh"
    
green_message "Success:" "Setup is now complete. Reboot to apply all changes."
