#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

bashd_dir="$HOME/Documents/linux_docs/configs/system/bash/bashrc.d"

for file in "$bashd_dir"/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done

for dir in helpers configure_packages install_packages; do
    for file in "$bashd_dir/$dir"/*.sh; do
        [ -e "$file" ] || continue
        . "$file"
    done
done

detect_system
print_system_info

ld_prefix="$HOME/Documents/linux_docs/scripts"

if [ "$swapfile_exists" -eq 1 ] && confirm "Remove swapfile? [y/N]"; then
    run_script "$ld_prefix/remove_swapfile.sh"

elif [ "$swapfile_exists" -eq 0 ] && [ "$swap_partition_exists" -eq 0 ] \
    && confirm "Create swapfile? [y/N]"; then
    run_script "$ld_prefix/create_swapfile.sh"
fi

exclude_from_array flatpaks "Flatpaks"

result=$(select_firefox_browser)
firefox_browser="${result%%|*}"
firefox_browser_uc="${result#*|}"

result=$(select_chromium_browser)
chromium_browser="${result%%|*}"
chromium_browser_uc="${result#*|}"

result=$(select_password_manager)
password_manager="${result%%|*}"
password_manager_uc="${result#*|}"

result=$(select_office_suite)
office_suite="${result%%|*}"
office_suite_uc="${result#*|}"

result=$(select_torrent_client)
torrent_client="${result%%|*}"
torrent_client_uc="${result#*|}"

result=$(select_vm_application)
vm_application="${result%%|*}"
vm_application_uc="${result#*|}"

print_field "Firefox Browser" "$firefox_browser_uc"
print_field "Chromium Browser" "$chromium_browser_uc"
print_field "Password Manager" "$password_manager_uc"
print_field "Office Suite" "$office_suite_uc"
print_field "Torrent Client" "$torrent_client_uc"
print_field "Virtual Machine Application" "$vm_application_uc"

install_codecs=0
install_redshift=0
install_gaming_pkgs=0

declare -A prompts=(
    [install_codecs]="Install codecs? [y/N]"
    [install_redshift]="Install redshift? [y/N]"
    [install_gaming_pkgs]="Install gaming packages? [y/N]"
)

ordered_prompt_vars=(
    install_codecs
    install_redshift
    install_gaming_pkgs
)

for var in "${ordered_prompt_vars[@]}"; do
    if confirm "${prompts[$var]}"; then
        printf -v "$var" '%s' 1
    fi
done

for var in "${ordered_prompt_vars[@]}"; do
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
    arch)
        enable_chaotic_aur
        ;;
    ubuntu)
        ;;
    debian)
        enable_debian_contrib
        enable_debian_backports
        ;;
    *)
        case " $os_like " in
            *" arch "* )
                enable_chaotic_aur
                ;;
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

if [ "$swapfile_exists" -eq 0 ] && [ "$swap_partition_exists" -eq 0 ]; then
    install_zram
fi

if [ "$primary_pm" != "rpm-ostree" ]; then
    install_pm_pkg_bypass "${micro_pkg[$primary_pm]}"
    install_pm_pkg_bypass "${rocm_smi_pkg[$primary_pm]}"

    if ! install_pm_pkg_bypass "fastfetch"; then
        install_pm_pkg_bypass "neofetch"
    fi
fi

case "$init_system" in
    systemd)
        if [ "$ram_gib" -gt 8 ] && systemctl list-unit-files --type=service --no-legend \
                | awk '{print $1}' \
                | grep -Fxq "systemd-oomd.service"; then

            enable_service "systemd-oomd.service"
            disable_service "earlyoom.service" || true
        else
            disable_service "systemd-oomd.service" || true
            install_pm_pkg_bypass "earlyoom" && configure_earlyoom
        fi
        ;;
    *)
        install_pm_pkg_bypass "earlyoom" && configure_earlyoom
        ;;
esac

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

install_fonts_microsoft

if ! grep -Fq "deno.bash" "$HOME/.bashrc"; then
    curl -fsSL https://deno.land/install.sh | sh
fi

ensure_pkg "flatpak" && flatpak_installed=1
[ "$flatpak_installed" -eq 1 ] && configure_flatpak

if [ "${#flatpaks[@]}" -ne 0 ]; then
    install_flatpak_pkg_bypass "${flatpaks[@]}"
fi

case "$primary_pm" in
    rpm-ostree)
        install_flatpak_pkg_bypass "${atomic_flatpaks[@]}"
        ;;
esac

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

case "$password_manager" in
    bitwarden) install_flatpak_pkg_bypass "com.bitwarden.desktop" ;;
    keepassxc) install_flatpak_pkg_bypass "org.keepassxc.KeePassXC" ;;
esac

case "$office_suite" in
    libreoffice) install_flatpak_pkg_bypass "org.libreoffice.LibreOffice" ;;
    onlyoffice) install_flatpak_pkg_bypass "org.onlyoffice.desktopeditors" ;;
esac

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
        case "$primary_pm" in
            rpm-ostree)
                if install_flatpak_pkg_bypass "com.transmissionbt.Transmission"; then
                    configure_transmission
                fi
                ;;
            *)
                if install_transmission; then
                    configure_transmission
                fi
                ;;
        esac
        ;;
esac

case "$primary_pm" in
    rpm-ostree)
        case "$vm_application" in
            gnome-boxes) install_flatpak_pkg_bypass "org.gnome.Boxes" ;;
            virt-manager) install_flatpak_pkg_bypass "org.virt_manager.virt-manager" ;;
        esac
        ;;
    *)
        case "$vm_application" in
            gnome-boxes) install_pm_pkg_bypass "gnome-boxes" ;;
            virt-manager) install_pm_pkg_bypass "virt-manager" ;;
        esac
        ;;
esac

setup_desktop

[ "$install_codecs" -eq 1 ] && install_codecs
[ "$install_redshift" -eq 1 ] && install_pm_pkg_bypass "${redshift_pkg[$primary_pm]}"
[ "$install_gaming_pkgs" -eq 1 ] && run_script "$ld_prefix/setup_gaming.sh"

add_firewall_exceptions
enable_permanent_mac_address

if [ "$battery_detected" -eq 1 ]; then
    add_kernel_parameter "preempt=voluntary"
else
    add_kernel_parameter "preempt=full"
fi

apply_pm_config

run_script "$ld_prefix/copy_pkg_configs.sh"
run_script "$ld_prefix/sync_bashrc_configs.sh"
    
green_message "Success:" "Setup is now complete. Reboot to apply all changes."
