# shellcheck shell=bash

# Enable nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Detect host system
host_system="unknown"
batteries=(/sys/class/power_supply/BAT*)

if (( ${#batteries[@]} )); then
    host_system="laptop"
else
    host_system="desktop"
fi

# Disable nullglob
shopt -u nullglob

# Define the operating system and convert it to lowercase
if [ -f /etc/os-release ]; then
    source /etc/os-release

    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"

    os="${os,,}"
    os_like="${os_like,,}"

    debian_version="0"
    ubuntu_version="0"
    linuxmint_version="0"
    fedora_version="0"
    openmandriva_version="0"
    opensuse_version="0"

    case "$os" in
        "debian")
            debian_version="${VERSION_ID-:0}"
            ;;
        "ubuntu")
            ubuntu_version="${VERSION_ID-:0}"
            ;;
        "linuxmint")
            linuxmint_version="${VERSION_ID:-0}"
            ;;
        "fedora")
            fedora_version="${VERSION_ID-:0}"
            ;;
        "openmandriva")
            openmandriva_version="${VERSION_ID-:0}"
            ;;
        "opensuse-leap")
            opensuse_version="${VERSION_ID-:0}"
            ;;
        *)
            case "$os_like" in
                "debian")
                    debian_version="${VERSION_ID-:0}"
                    ;;
                "ubuntu debian")
                    ubuntu_version="${VERSION_ID-:0}"
                    ;;
                "fedora")
                    fedora_version="${VERSION_ID-:0}"
                    ;;
            esac
            ;;
    esac
fi

# Define package managers
primary_package_manager="unknown"
secondary_package_manager="unknown"

primary_package_managers=(apt dnf eopkg pacman xbps-install zypper rpm-ostree)
secondary_package_managers=(nala paru yay)

for cmd in "${primary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        primary_package_manager="$cmd"
        break
    fi
done

for cmd in "${secondary_package_managers[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        secondary_package_manager="$cmd"
        break
    fi
done

if [ "$primary_package_manager" = "xbps-install" ]; then
    primary_package_manager="xbps"
fi

# Check for Flatpak
flatpak_installed=0
if command -v flatpak >/dev/null 2>&1; then
    flatpak_installed=1
fi

# Check for Snap
snap_installed=0
if command -v snap >/dev/null 2>&1; then
    snap_installed=1
    export PATH="$PATH:/usr/sbin:/snap/bin"
fi

# Check for Toolbox
toolbox_installed=0
if command -v toolbox >/dev/null 2>&1 || command -v podman-toolbox >/dev/null 2>&1; then
    toolbox_installed=1
fi

# Define the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Define init system
init_system="unknown"
init_names=(systemd runit sysvinit openrc-init dinit)
pid1_comm=$(ps -p 1 -o comm=)

for init_name in "${init_names[@]}"; do
    if [ "$pid1_comm" = "$init_name" ]; then
        init_system="$init_name"
        break
    fi
done

# Define init system
init_system="unknown"
pid1_comm=$(ps -p 1 -o comm=)

case "$pid1_comm" in
    "systemd"|"dinit"|"runit")
        init_system="$pid1_comm"
        ;;
    "openrc-init")
        init_system="openrc"
        ;;
    "s6-linux-init")
        init_system="s6"
        ;;
    "init")
        init_system="sysvinit"
        ;;
esac

# Define bootloader
bootloader="unknown"
update_bootloader="unknown"

if command -v update-grub >/dev/null 2>&1 || command -v /usr/sbin/update-grub >/dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="update-grub"

elif command -v grub2-mkconfig >/dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub2-mkconfig -o /boot/grub2/grub.cfg"

elif command -v grub-mkconfig >/dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub-mkconfig -o /boot/grub/grub.cfg"

elif command -v limine-update >/dev/null 2>&1; then
    bootloader="limine"
    update_bootloader="limine-update"

elif find /boot/efi/EFI -name "*systemd-boot*.efi" >/dev/null 2>&1; then
    bootloader="systemd-boot"
    update_bootloader="bootctl update"
fi

# Define file systems of root and home directory
root_filesystem="$(df -T / | awk 'NR==2 {print $2}')"
home_filesystem="$(df -T /home | awk 'NR==2 {print $2}')"

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Define command to get display information
display_cmd="unknown"
if command -v xrandr >/dev/null 2>&1; then
    display_cmd="xrandr"
elif command -v wlr-randr >dev/null 2>&1; then
    display_cmd="wlr-randr"
fi

# Get display information
if [ "$display_cmd" != "unknown" ]; then
    display="$("$display_cmd" | grep "primary" -A1 | tail -1 | awk '{print $1}')"
    display_w="$(echo "$display" | cut -d'x' -f1)"
    display_h="$(echo "$display" | cut -d'x' -f2)"
    refresh_rate="$("$display_cmd"  | grep "primary" -A1 | tail -1 | awk '{print $2}' | sed 's/[*+]//g' | xargs printf "%.0f")"
    max_fps_target="$(awk "BEGIN {printf \"%.0f\", int(($refresh_rate - 5) / 5 + 0.5) * 5}")"
fi
