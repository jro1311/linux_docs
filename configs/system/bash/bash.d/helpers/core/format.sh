# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

red_message() {
    local label="$1"
    local value="${2:-}"
    echo "${red}$label${reset} $value" >&2
}

green_message() {
    local label="$1"
    local value="${2:-}"
    echo "${green}$label${reset} $value" >&2
}

yellow_message() {
    local label="$1"
    local value="${2:-}"
    echo "${yellow}$label${reset} $value" >&2
}

blue_message() {
    local label="$1"
    local value="${2:-}"
    echo "${blue}$label${reset} $value" >&2
}

print_field() {
    assert_arity "$#" eq 2 "<label> <value>" || return 1
    detect_system

    local label="$1"
    local var="$2"

    if [ -z "$var" ] || [ "$var" = 0 ]; then
        return 0
    fi

    green_message "$label:" "$var"
}

confirm_proceed() {
    read -r -p "Press ${green}ENTER${reset} to proceed or ${red}CTRL+C${reset} to cancel: "
}

confirm() {
    local prompt="$1"
    local answer default

    if [ -z "$prompt" ]; then
        prompt="Confirm? [y/N]"
    fi

    case "$prompt" in
        *"[Y/n]"*) default="y" ;;
        *"[y/N]"*) default="n" ;;
        *) default="n" ;;
    esac

    while true; do
        read -r -p "$prompt: " answer
        answer="${answer:-$default}"

        case "$answer" in
            [Yy]) return 0 ;;
            [Nn]) return 1 ;;
            *) continue ;;
        esac
    done
}

normalize_pkg() {
    local pkg="$1"

    detect_system

    case "$os" in
        debian)
            case "$pkg" in
                firefox) pkg="firefox-esr" ;;
            esac
            ;;
        *)
            case " $os_like " in
                *" debian "*)
                    case "$pkg" in
                        firefox) pkg="firefox-esr" ;;
                    esac
                    ;;
            esac
            ;;
    esac

    case "$primary_pm" in
        apt)
            case "$pkg" in
                compsize)       pkg="btrfs-compsize" ;;
                steam)          pkg="steam-installer" ;;
                zram-generator) pkg="systemd-zram-generator" ;;
            esac
            ;;
        dnf|rpm-ostree)
            case "$pkg" in
                shellcheck)     pkg="ShellCheck" ;;
            esac
            ;;
        eopkg)
            ;;
        pacman)
            case "$pkg" in
                redshift-gtk)   pkg="redshift" ;;
                rocm-smi)       pkg="rocm-smi-lib" ;;
            esac
            ;;
        xbps)
            case "$pkg" in
                cpu-x)          pkg="CPU-X" ;;
                lact)           pkg="LACT" ;;
                rocm-smi)       pkg="ROCm-SMI" ;;
                mangohud)       pkg="MangoHud" ;;
                zram-generator) pkg="zramen" ;;
            esac
            ;;
        zypper)
            case "$pkg" in
                micro) pkg="micro-editor" ;;
            esac
            ;;
    esac

    case "$pkg" in
        transmission)
            if is_qt_preferred_env "$desktop"; then
                pkg="${transmission_qt_pkg[$primary_pm]}"
            else
                pkg="${transmission_gtk_pkg[$primary_pm]}"
            fi
            ;;
    esac

    printf '%s\n' "$pkg"
}

collect_text_files() {
    local target_dir="$1"
    local -n export_array="$2"
    local find_args=() ext_files=() noext_files=()
    local ext

    target_dir="${target_dir%/}"

    local include_exts=(
        # General
        txt
        md
        csv
        tsv

        # Config
        conf
        cfg
        ini
        json
        yaml
        yml
        toml
        env
        properties

        # Shell
        sh
        bash
        zsh

        # Web
        js
        ts
        css
        html
        xml

        # Programming
        py
        rb
        lua
        c
        h
        cpp
        go
        rs

        # Misc
        dockerfile
        gitignore
        gitattributes
        mk
    )

    for ext in "${include_exts[@]}"; do
        find_args+=( -iname "*.${ext}" -o )
    done
    unset 'find_args[${#find_args[@]}-1]'

    mapfile -t ext_files < <(
        find "$target_dir" \
            -path '*/.git' -prune -o \
            -type f \( "${find_args[@]}" \) -print
    )

    if command -v file >/dev/null 2>&1; then
        mapfile -t noext_files < <(
            find "$target_dir" \
                -path '*/.git' -prune -o \
                -type f -not -name "*.*" -print0 |
            xargs -0 -r file --mime-type |
            awk -F: '$2 ~ /text\// {print $1}'
        )
    else
        yellow_message "Skipped:" "Extensionless files (no 'file' utility available)."
    fi

    export_array=( "${ext_files[@]}" "${noext_files[@]}" )
}

format_nanoseconds() {
    local ns="$1"
    local us=$(( ns / 1000 ))
    local ms=$(( ns / 1000000 ))
    local sec=$(( ns / 1000000000 ))
    local ms_rem=$(( (ns / 1000000) % 1000 ))

    if [ "$ns" -lt 1000 ]; then
        printf '%d ns' "$ns"

    elif [ "$us" -lt 1000 ]; then
        printf '%d µs' "$us"

    elif [ "$ms" -lt 1000 ]; then
        printf '%d ms' "$ms"

    else
        printf '%d.%03d s' "$sec" "$ms_rem"
    fi
}

bytes_to_bits() {
    local bytes="$1"
    local bits

    bits=$(( bytes * 8 ))
    printf "%s" "$bits"
}

bits_to_bytes() {
    local bits="$1"
    local bytes

    bytes=$(( bits / 8 ))
    printf "%s" "$bytes"
}

binary_to_decimal() {
    local value="$1"
    local decimal

    decimal=$(awk "BEGIN { printf \"%.1f\", $value * 1000 / 1024 }")
    printf "%s" "$decimal"
}

decimal_to_binary() {
    local value="$1"
    local binary

    binary=$(awk "BEGIN { printf \"%.1f\", $value * 1024 / 1000 }")
    printf "%s" "$binary"
}

format_bytes_binary() {
    local bytes="$1"
    local value units

    if [ "$bytes" -ge $((1024*1024*1024*1024)) ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bytes / (1024*1024*1024*1024) }")
        units="TiB"

    elif [ "$bytes" -ge $((1024*1024*1024)) ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bytes / (1024*1024*1024) }")
        units="GiB"

    elif [ "$bytes" -ge $((1024*1024)) ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bytes / (1024*1024) }")
        units="MiB"

    elif [ "$bytes" -ge 1024 ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bytes / 1024 }")
        units="KiB"

    else
        value=$(printf "%s" "$bytes")
        units="Bytes"
    fi

    printf "%s %s" "$value" "$units"
}

format_bytes_decimal() {
    local bytes="$1"
    local value units

    if [ "$bytes" -ge 1000000000000 ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bytes / 1000000000000 }")
        units="TB"

    elif [ "$bytes" -ge 1000000000 ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bytes / 1000000000 }")
        units="GB"

    elif [ "$bytes" -ge 1000000 ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bytes / 1000000 }")
        units="MB"

    elif [ "$bytes" -ge 1000 ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bytes / 1000 }")
        units="kB"

    else
        value=$(printf "%s" "$bytes")
        units="Bytes"
    fi

    printf "%s %s" "$value" "$units"
}

format_bits_binary() {
    local bits="$1"
    local value units

    if [ "$bits" -ge $((1024*1024*1024*1024)) ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bits / (1024*1024*1024*1024) }")
        units="Tib"

    elif [ "$bits" -ge $((1024*1024*1024)) ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bits / (1024*1024*1024) }")
        units="Gib"

    elif [ "$bits" -ge $((1024*1024)) ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bits / (1024*1024) }")
        units="Mib"

    elif [ "$bits" -ge 1024 ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bits / 1024 }")
        units="Kib"

    else
        value=$(printf "%s" "$bits")
        units="bits"
    fi

    printf "%s %s" "$value" "$units"
}

format_bits_decimal() {
    local bits="$1"
    local value units

    if [ "$bits" -ge 1000000000000 ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bits / 1000000000000 }")
        units="Tb"

    elif [ "$bits" -ge 1000000000 ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bits / 1000000000 }")
        units="Gb"

    elif [ "$bits" -ge 1000000 ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bits / 1000000 }")
        units="Mb"

    elif [ "$bits" -ge 1000 ]; then
        value=$(awk "BEGIN { printf \"%.1f\", $bits / 1000 }")
        units="kb"

    else
        value=$(printf "%s" "$bits")
        units="bits"
    fi

    printf "%s %s" "$value" "$units"
}

