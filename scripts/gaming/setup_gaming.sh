#!/usr/bin/env bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

set -euo pipefail

ld_bash_dir="$HOME/Documents/linux_docs/configs/system/bash/bash.d"

shopt -s nullglob globstar
for file in "$ld_bash_dir"/**/*.sh; do
    [ -e "$file" ] || continue
    . "$file"
done
shopt -u nullglob globstar

detect_system

gpu_config_tool=${1:-}
remove_non_selected_pkgs=${2:-}

if [ -z "$gpu_config_tool" ]; then
    result=$(select_gpu_config_tool)
    gpu_config_tool="${result%%|*}"
    gpu_config_tool_label="${result#*|}"

    print_field "GPU Configuration Tool" "$gpu_config_tool_label"
    exclude_from_array "gaming_flatpaks" "Gaming Flatpaks"
fi

remove_non_selected_pkgs=$(resolve_flag \
    "$remove_non_selected_pkgs" \
    "Remove non-selected packages if installed? [y/N]"
)

make_keys "gpu_config_tool"

if [ "$remove_non_selected_pkgs" -eq 1 ]; then
    remove_non_selected_pkg "gpu_config_tool" "$gpu_config_tool" "${gpu_config_tool_keys[@]}"
fi

case "$gpu_config_tool" in
    lact)
        if install_lact; then
            configure_lact
        fi
        ;;
    corectrl)
        if install_corectrl; then
            configure_corectrl
        fi
        ;;
esac

case "$primary_pm" in
    apt)    sudo dpkg --add-architecture i386 && sudo apt-get update ;;
    zypper) ensure_pkg "selinux-policy-targeted-gaming" ;;
esac

case "$primary_pm" in
    rpm-ostree) ;;
    *) ensure_pkg "steam" ;;
esac

if install_mangohud; then
    configure_mangohud
fi

if [ "$flatpak_installed" -eq 1 ]; then
    configure_flatpak

    if [ "${#gaming_flatpaks[@]}" -ne 0 ]; then
        for flatpak in "${gaming_flatpaks[@]}"; do
            if ! pkg_installed_flatpak "$flatpak"; then
                install_flatpak_pkg_bypass "$flatpak"
            fi
        done
    fi

    case "$primary_pm" in
        rpm-ostree)
            if ! pkg_installed_flatpak "com.valvesoftware.Steam"; then
                install_flatpak_pkg_bypass "com.valvesoftware.Steam"
            fi
            ;;
    esac

    flatpak_overrides=(
        "org.prismlauncher.PrismLauncher"
        "com.heroicgameslauncher.hgl"
        "com.geeks3d.furmark"
    )

    # Grants read-only access to MangoHud's config file
    for flatpak in "${flatpak_overrides[@]}"; do
        flatpak override --user --filesystem=xdg-config/MangoHud:ro "$flatpak" || :
    done
fi

green_message "Success:" "Gaming setup is complete."
