#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2154

resolve_packages() {
    resolved_pkgs=()
    local pkg

    for pkg in "${universal_pkgs[@]}"; do
        resolved_pkgs+=("$(normalize_pkg "$pkg")")
    done

    case "$os" in
        arch)               resolved_pkgs+=("${arch_pkgs[@]}") ;;
        debian)             resolved_pkgs+=("${debian_pkgs[@]}") ;;
        fedora)             resolved_pkgs+=("${fedora_pkgs[@]}") ;;
        opensuse*|suse)     resolved_pkgs+=("${opensuse_pkgs[@]}") ;;
        openmandriva)       resolved_pkgs+=("${openmandriva_pkgs[@]}") ;;
        solus)              resolved_pkgs+=("${solus_pkgs[@]}") ;;
        void)               resolved_pkgs+=("${void_pkgs[@]}") ;;
        *)
            case " $os_like " in
                *" arch "*)                 resolved_pkgs+=("${arch_pkgs[@]}") ;;
                *" debian "*)               resolved_pkgs+=("${debian_pkgs[@]}") ;;
                *" fedora "*)               resolved_pkgs+=("${fedora_pkgs[@]}") ;;
                *" opensuse "*|*" suse "*)  resolved_pkgs+=("${opensuse_pkgs[@]}") ;;
                *" solus "*)                resolved_pkgs+=("${solus_pkgs[@]}") ;;
                *" void "*)                 resolved_pkgs+=("${void_pkgs[@]}") ;;
            esac
    esac
}

resolve_flatpaks() {
    resolved_flatpaks=()
    local pkg

    for pkg in "${flatpaks[@]}"; do
        resolved_flatpaks+=("$pkg")
    done

    for pkg in "${atomic_flatpaks[@]}"; do
        resolved_flatpaks+=("$pkg")
    done
}
