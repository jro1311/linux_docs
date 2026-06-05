# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

assert_arity() {
    case "$2" in
        eq|ge|le|any)
            if [ "$#" -ne 4 ]; then
                red_message "assert_arity:" "expected 4 argument(s) <actual> <mode> <needed> <signature>"
                return 1
            fi
            ;;
        range)
            if [ "$#" -ne 5 ]; then
                red_message "assert_arity:" "expected 5 argument(s) <actual> range <min> <max> <signature>"
                return 1
            fi
            ;;
        *)
            red_message "assert_arity:" "invalid mode '$2'"
            return 1
            ;;
    esac

    local actual="$1"
    local mode="$2"
    local value="$3"
    local min="$3"
    local max="${4-}"
    local signature="${5-}"

    local caller="${FUNCNAME[1]}"

    case "$mode" in
        eq)
            if [ "$actual" -ne "$value" ]; then
                red_message "${caller}:" "expected $value argument(s) $signature"
                return 1
            fi
            ;;
        ge)
            if [ "$actual" -lt "$value" ]; then
                red_message "${caller}:" "expected min $value argument(s) $signature"
                return 1
            fi
            ;;
        le)
            if [ "$actual" -gt "$value" ]; then
                red_message "${caller}:" "expected max $value argument(s) $signature"
                return 1
            fi
            ;;
        range)
            if [ "$actual" -lt "$min" ] || [ "$actual" -gt "$max" ]; then
                red_message "${caller}:" "expected $min to $max argument(s) $signature"
                return 1
            fi
            ;;
        any)
            ;;
    esac
}

resolve_flag() {
    local value="$1"
    local prompt="$2"

    case "$value" in
        0) printf 0 ;;
        1) printf 1 ;;
        *)
            if confirm "$prompt"; then
                printf 1
            else
                printf 0
            fi
            ;;
    esac
}

resolve_script() {
    local target="$1"
    local base="$LD_SCR"

    local found
    found=$(find "$base" -type f -name "$target" 2>/dev/null | head -n 1)

    if [ -z "$found" ]; then
        red_message "Error:" "'$target' script not found in '$base'."
        return 1
    fi

    printf "%s\n" "$found"
}

source_exists() {
    local path="$1"

    if [ ! -e "$path" ]; then
        red_message "Error:" "'$path' does not exist."
        return 1
    fi
}

copy_config() {
    assert_arity "$#" "ge" 3 "<overwrite_flag> <source> <target> [origin]" || return 1

    local overwrite="$1"
    local source="$2"
    local target="$3"
    local origin="${4:-}"
    local label

    source_exists "$source" || return 1

    label="$(basename "$target")"

    if [ -n "$origin" ]; then
        label="$label ($origin)"
    fi

    case "$target" in
        "$HOME"*)  label="$label" ;;
        *)         label="$label (system)" ;;
    esac

    if [ "$overwrite" -eq 1 ] || [ ! -f "$target" ]; then
        sudo_run rm -f "$target" || :
        sudo_run mkdir -p "$(dirname "$target")" || return 1
        sudo_run cp "$source" "$target" || return 1
        success_configs+=("$label")
    else
        skipped_configs+=("$label")
    fi
}

copy_config_dir() {
    assert_arity "$#" "ge" 3 "<overwrite_flag> <source> <target_parent> [origin]" || return 1

    local overwrite="$1"
    local source="$2"
    local target_parent="$3"
    local origin="${4:-}"

    source_exists "$source" || return 1

    local name label
    name="$(basename "$source")"
    label="$name"
    local target="${target_parent}/${name}"

    if [ -n "$origin" ]; then
        label="$label ($origin)"
    fi

    case "$target" in
        "$HOME"*)  label="$label" ;;
        *)         label="$label (system)" ;;
    esac

    if [ "$overwrite" -eq 1 ] || [ ! -d "$target" ]; then
        sudo_run rm -rf "$target" || :
        sudo_run mkdir -p "$target_parent" || return 1
        sudo_run cp -r "$source" "$target" || return 1
        success_configs+=("$label")
    else
        skipped_configs+=("$label")
    fi
}

restorecon_paths() {
    command -v restorecon >/dev/null 2>&1 || return 0

    local path

    for path in "$@"; do
        if [ -e "$path" ]; then
            sudo restorecon -RF "$path" || return 1
        fi
    done
}

set_kv_option() {
    assert_arity "$#" "ge" 4 "<format> <key> <value> <file>" || return 1

    local format="$1"
    local key="$2"
    local value="$3"
    local sep file
    shift 3

    case "$format" in
        compact) sep="=" ;;
        spaced) sep=" = " ;;
        *) return 1 ;;
    esac

    for file in "$@"; do
        if grep -Eq "^${key}[[:space:]]*=" "$file" 2>/dev/null ; then
            sudo_run sed -i "s|^${key}[[:space:]]*=.*|${key}${sep}${value}|" "$file" || :
        else
            printf '%s\n' "${key}${sep}${value}" | sudo_run tee -a "$file" >/dev/null || :
        fi
    done
}

pkg_installed_pm() {
    local pkg="$1"

    detect_system

    case "$primary_pm" in
        apt)
            dpkg -s "$pkg" >/dev/null 2>&1
            ;;
        dnf|rpm-ostree)
            rpm -q "$pkg" >/dev/null 2>&1
            ;;
        eopkg)
            eopkg search -i --name "^$pkg$" 2>/dev/null \
                | awk -F' - ' '{print $1}' \
                | grep -Fq "$pkg"
            ;;
        pacman)
            pacman -Qq "$pkg" >/dev/null 2>&1
            ;;
        xbps)
            xbps-query -p pkgver "$pkg" >/dev/null 2>&1
            ;;
        zypper)
            zypper se -i --match-exact "$pkg" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

pkg_installed_aur() {
    local pkg="$1"

    detect_system

    [ "$primary_pm" = "pacman" ] || return 1
    [ -n "$secondary_pm" ]       || return 1

    "$secondary_pm" -Qq "$pkg" >/dev/null 2>&1
}

pkg_installed_toolbox() {
    local pkg="$1"

    detect_system

    [ "$toolbox_installed" -eq 1 ] || return 1

    toolbox run rpm -q "$pkg" >/dev/null 2>&1
}

pkg_installed_flatpak() {
    local pkg="$1"

    detect_system

    [ "$flatpak_installed" -eq 1 ] || return 1

    flatpak list --columns=application 2>/dev/null | grep -Fiq "$pkg"
}

pkg_installed_snap() {
    local pkg="$1"

    detect_system

    [ "$snap_installed" -eq 1 ] || return 1

    snap list "$pkg" >/dev/null 2>&1
}

pkg_available_pm() {
    local pkg="$1"

    detect_system

    case "$primary_pm" in
        apt)
            apt-cache policy "$pkg" 2>/dev/null | grep -Fq "Candidate:"
            ;;
        dnf)
            dnf repoquery --quiet --qf '%{name}' "$pkg" 2>/dev/null | grep -Fxq "$pkg"
            ;;
        eopkg)
            eopkg search --name "^$pkg$" 2>/dev/null \
                | awk -F' - ' '{print $1}' \
                | grep -Fq "$pkg"
            ;;
        pacman)
            pacman -Si "$pkg" >/dev/null 2>&1
            ;;
        xbps)
            xbps-query -R "$pkg" >/dev/null 2>&1
            ;;
        zypper)
            zypper se --match-exact "$pkg" >/dev/null 2>&1
            ;;
        rpm-ostree)
            rpm-ostree install --dry-run "$pkg" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

pkg_available_aur() {
    local pkg="$1"

    detect_system

    [ "$primary_pm" = "pacman" ] || return 1
    [ -n "$secondary_pm" ]       || return 1

    "$secondary_pm" -Si "$pkg" >/dev/null 2>&1
}

pkg_available_toolbox() {
    local pkg="$1"

    detect_system

    [ "$toolbox_installed" -eq 1 ] || return 1

    toolbox run dnf repoquery --quiet "$pkg" >/dev/null 2>&1
}

pkg_available_flatpak() {
    local pkg="$1"

    detect_system

    [ "$flatpak_installed" -eq 1 ] || return 1

    flatpak search --columns=application "$pkg" 2>/dev/null | grep -Fiq "$pkg"
}

pkg_available_snap() {
    local pkg="$1"

    detect_system

    [ "$snap_installed" -eq 1 ] || return 1

    snap info "$pkg" >/dev/null 2>&1
}

in_array() {
    local needle=$1
    shift

    for item in "$@"; do
        [ "$item" = "$needle" ] && return 0
    done

    return 1
}

strip_trailing_slash() {
    case "$1" in
        */) printf '%s\n' "${1%/}" ;;
        *)  printf '%s\n' "$1" ;;
    esac
}

apply_utf16_substitutions() {
    assert_arity "$#" "ge" 2 "<filename> <patterns>" || return 1

    local file="$1"
    shift
    local patterns=("$@")

    # Converts file to utf8, makes changes, then converts it back
    local tmp="${file}.utf8"

    iconv -f utf-16le -t utf-8 "$file" > "$tmp" || return 1

    for pattern in "${patterns[@]}"; do
        sed -i "$pattern" "$tmp" || return 1
    done

    iconv -f utf-8 -t utf-16le "$tmp" > "$file" || return 1
    rm -f "$tmp" || return 1
}
