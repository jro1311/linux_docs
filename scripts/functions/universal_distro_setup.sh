#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Enables nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Detect host system
host_system="unknown"
batteries=(/sys/class/power_supply/BAT*)

if (( ${#batteries[@]} )); then
    host_system="laptop"
else
    host_system="desktop"
fi

if [ "$host_system" != "unknown" ]; then
    echo "${green}Host System: $host_system ${reset}"
fi

# Disables nullglob
shopt -u nullglob

# Define the operating system and convert it to lowercase
if [ -f /etc/os-release ]; then
    . /etc/os-release

    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"

    os="${os,,}"
    os_like="${os_like,,}"

    echo "${green}Distro (ID): $os ${reset}"
    echo "${green}Distro (ID_LIKE): $os_like ${reset}"

else
    echo "${red}Unable to detect the operating system. ${reset}"
    exit 1
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

if [ "$primary_package_manager" != "unknown" ]; then
    echo "${green}Primary Package Manager: $primary_package_manager ${reset}"
fi

if [ "$secondary_package_manager" != "unknown" ]; then
    echo "${green}Secondary Package Manager: $secondary_package_manager ${reset}"
fi

# Check for Flatpak
flatpak_installed=0
if command -v flatpak > /dev/null 2>&1; then
    flatpak_installed=1
    echo "${green}Flatpak detected. ${reset}"
fi

# Check for Snap
snap_installed=0
if command -v snap > /dev/null 2>&1; then
    snap_installed=1
    echo "${green}Snap detected. ${reset}"
fi

# Check for Toolbox
toolbox_installed=0
if command -v toolbox >/dev/null 2>&1; then
    toolbox_installed=1
    echo "${green}Toolbox detected. ${reset}"
fi

# Define the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')
echo "${green}Desktop: $desktop ${reset}"

# Define init system
init_system="unknown"
init_names=(systemd runit sysvinit openrc-init)
pid1_comm=$(ps -p 1 -o comm=)

for init_name in "${init_names[@]}"; do
    if [ "$pid1_comm" = "$init_name" ]; then
        init_system="$init_name"
        break
    fi
done

if [ "$init_system" != "unknown" ]; then
    echo "${green}Init System: $init_system ${reset}"
fi

# Define bootloader
bootloader="unknown"
update_bootloader="unknown"

if command -v update-grub > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="update-grub"

elif command -v grub2-mkconfig > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub2-mkconfig -o /boot/grub2/grub.cfg"

elif command -v grub-mkconfig > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub-mkconfig -o /boot/grub/grub.cfg"

elif command -v limine-update > /dev/null 2>&1; then
    bootloader="limine"
    update_bootloader="limine-update"

elif find /boot/efi/EFI -name "*systemd-boot*.efi" > /dev/null 2>&1; then
    bootloader="systemd-boot"
    update_bootloader="bootctl update"
fi

if [ "$bootloader" != "unknown" ]; then
    echo "${green}Bootloader: $bootloader ${reset}"
fi

# Define file system of root directory
root_filesystem="$(df -T / | awk 'NR==2 {print $2}')"
echo "${green}Root File System: $root_filesystem ${reset}"

# Define file system of home directory
home_filesystem="$(df -T /home | awk 'NR==2 {print $2}')"
echo "${green}Home File System: $home_filesystem ${reset}"

# Checks for swapfile
if [[ -f /swapfile || -f /swap/swapfile || -f /swap.img ]]; then

    # Function for user input
    remove_swapfile() {
        local answer
        while true; do
            read -r -p "Remove swapfile? [Y/n]: " answer
            answer="${answer:-y}"

            case "$answer" in
                [Yy])
                    return 0
                    ;;
                [Nn]*)
                    return 1
                    ;;
                *)
                    echo "Enter a 'y' or 'n'."
                    ;;
            esac

        done
    }

    # Checks for answer
    if remove_swapfile; then

        # Checks for swapfile and removes it
        if [ -f /swapfile ]; then
            sudo swapoff /swapfile
            sudo rm -v /swapfile
            sudo sed -i '/\/swapfile/d' /etc/fstab

        elif [ -f /swap/swapfile ]; then
            sudo swapoff /swap/swapfile
            sudo rm -v /swap/swapfile
            sudo sed -i '/\/swap\/swapfile/d' /etc/fstab

            if [ "$root_filesystem" = "btrfs" ]; then
                sudo btrfs subvolume delete /swap
            fi

        elif [ -f /swap.img ]; then
            sudo swapoff /swap.img
            sudo rm -v /swap.img
            sudo sed -i '/\/swap.img/d' /etc/fstab
        fi

    fi

else
    echo "${yellow}No swapfile detected. ${reset}"
fi

# Function for user input
install_codecs() {
    local answer
    while true; do
        read -r -p "Install multimedia codecs? [Y/n]: " answer
        answer="${answer:-y}"

        case "$answer" in
            [Yy])
                return 0
                ;;
            [Nn])
                return 1
                ;;
            *)
                echo "Enter a 'y' or 'n'."
                ;;
        esac
    done
}

# Function for user input
install_gaming_packages() {
    local answer
    while true; do
        read -r -p "Install gaming packages? [Y/n]: " answer
        answer="${answer:-y}"

        case "$answer" in
            [Yy])
                return 0
                ;;
            [Nn])
                return 1
                ;;
            *)
                echo "Enter a 'y' or 'n'."
                ;;
        esac

    done
}

# Function for user input
add_autostart_transmission() {
    local answer
    while true; do
        read -r -p "Add Transmission to autostart? [Y/n]: " answer
        answer="${answer:-y}"

        case "$answer" in
            [Yy])
                return 0
                ;;
            [Nn])
                return 1
                ;;
            *)
                echo "Enter a 'y' or 'n'."
                ;;
        esac
    done
}

# Prompts user for input
read -r -p "Press enter to proceed, or ctrl+c to cancel: "

# Checks root filesystem
if [ "$root_filesystem" = "btrfs" ]; then

    # Makes directory(s)
    sudo mkdir -pv /var/lib/flatpak
    sudo mkdir -pv /var/lib/libvirt/images
    sudo mkdir -pv /var/lib/machines
    sudo mkdir -pv /var/log/journal

    # Enables COW on specific directory(s)
    sudo chattr -C /var/lib/flatpak

    # Disables COW on specific directory(s)
    sudo chattr +C /var/lib/libvirt/images
    sudo chattr +C /var/lib/machines
    sudo chattr +C /var/log/journal

fi

# Checks home filesystem
if [ "$home_filesystem" = "btrfs" ]; then

    # Makes directory(s)
    mkdir -pv "$HOME/.local/share/flatpak"
    mkdir -pv "$HOME/.local/share/gnome-boxes/images"
    mkdir -pv "$HOME/.var/app/org.gnome.Boxes/data/gnome-boxes/images"

    # Enables COW on specific directory(s)
    chattr -C "$HOME/.local/share/flatpak"

    # Disables COW on specific directory(s)
    chattr +C "$HOME/.local/share/gnome-boxes/images"
    chattr +C "$HOME/.var/app/org.gnome.Boxes/data/gnome-boxes/images"

fi

# Check for package or package manager
check() {
    local cmd="$1"
    shift
    if command -v "$cmd"; then
        "$@"
    fi
}

# Checks primary package manager and remove package(s)
case "$primary_package_manager" in
    "apt")
        check firefox-esr sudo apt-get remove -y firefox-esr
        check /usr/bin/firefox sudo apt-get remove -y firefox
        check /snap/bin/firefox sudo snap remove firefox
        check libreoffice sudo apt-get remove -y libreoffice*
        ;;
    "dnf")
        [ "$os" = "openmandriva" ] && check chromium sudo dnf remove -y chromium
        check firefox sudo dnf remove -y firefox
        check libreoffice sudo dnf remove -y libreoffice*
        ;;
    "eopkg")
        check firefox sudo eopkg remove -y firefox
        check libreoffice sudo eopkg remove -y libreoffice*
        ;;
    "pacman")
        check firefox sudo pacman -Rs --noconfirm firefox
        check libreoffice sudo pacman -Rs --noconfirm libreoffice*
        ;;
    "xbps")
        check firefox sudo xbps-remove -Ry firefox
        check libreoffice sudo xbps-remove -Ry libreoffice*
        ;;
    "zypper")
        check vlc sudo zypper rm --clean-deps -y vlc
        check MozillaFirefox sudo zypper rm --clean-deps -y MozillaFirefox
        check libreoffice sudo zypper rm --clean-deps -y libreoffice*
        ;;
    "rpm-ostree")
        check firefox sudo rpm-ostree override remove firefox firefox-langpacks
        check libreoffice sudo rpm-ostree override remove libreoffice
        ;;
esac

# Package manager array
managers=(apt dnf eopkg pacman xbps zypper flatpak snap rpm-ostree)

# Loops through package managers and upgrades system
for manager in "${managers[@]}"; do
    case "$manager" in
        "apt")
            if [ "$primary_package_manager" = "apt" ]; then
                sudo apt-get update && sudo apt-get full-upgrade -y
            fi
            ;;
        "dnf")
            if [ "$primary_package_manager" = "dnf" ]; then
                sudo dnf upgrade -y
            fi
            ;;
        "eopkg")
            if [ "$primary_package_manager" = "eopkg" ]; then
                sudo eopkg upgrade -y
            fi
            ;;
        "pacman")
            if [[ "$secondary_package_manager" =~ ^(paru|yay)$ ]]; then
                "$secondary_package_manager" -Syu --noconfirm

            elif [ "$primary_package_manager" = "pacman" ]; then
                sudo pacman -Syu --noconfirm
            fi
            ;;
        "xbps")
            if [ "$primary_package_manager" = "xbps" ]; then
                sudo xbps-install -Suy xbps && sudo xbps-install -uy
            fi
            ;;
        "zypper")
            if [ "$primary_package_manager" = "zypper" ]; then
            
                if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
                    sudo zypper ref && sudo zypper dup -y

                elif [ "$os" = "opensuse-leap" ]; then
                    sudo zypper ref && sudo zypper up -y
                fi
                
            fi
            ;;
        "flatpak")
            if [ "$flatpak_installed" -eq 1 ]; then
                flatpak update -y
            fi
            ;;
        "snap")
            if [ "$snap_installed" -eq 1 ]; then
                sudo snap refresh
            fi
            ;;
        "rpm-ostree")
            if [ "$primary_package_manager" = "rpm-ostree" ]; then
                sudo rpm-ostree upgrade
            fi
            ;;
    esac
done

# Checks for answer
if install_codecs; then

    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_install.sh"

fi

# List of universal packages
universal_packages=(
"bash-completion"
"btop"
"curl"
"dos2unix"
"flatpak"
"fontconfig"
"fwupd"
"gawk"
"git"
"gnome-boxes"
"gnome-disk-utility"
"gsmartcontrol"
"hplip"
"htop"
"inxi"
"jq"
"mpv"
"nano"
"ntfs-3g"
"pciutils"
"shellcheck"
"smartmontools"
"tealdeer"
"yt-dlp"
)

# List of distro-specific packages
arch_packages=(
"cpu-x"
"fastfetch"
"linux-lts"
"memtest86+"
"micro"
"zram-generator"
)

aur_packages=(
"nano-syntax-highlighting"
"ttf-ms-win11-auto"
)

debian_packages=(
"cpu-x"
"hplip-gui"
"memtest86+"
"micro"
"nala"
"neofetch"
"systemd-zram-generator"
"ttf-mscorefonts-installer"
)

atomic_packages=(
"gnome-disk-utility"
"hplip"
"hplip-gui"
)

fedora_packages=(
"cabextract"
"cpu-x"
"fastfetch"
"google-noto-sans-jp-fonts"
"google-noto-sans-kr-fonts"
"hplip-gui"
"memtest86+"
"micro"
"xorg-x11-font-utils"
"zram-generator"
)

openmandriva_packages=(
"cpu-x"
"fastfetch"
"fonts-ttf-japanese"
"fonts-ttf-korean"
"hplip-gui"
"memtest86+"
"micro"
"zram-generator"
)

opensuse_packages=(
"cpu-x"
"fastfetch"
"fetchmsttfonts"
"grub2-snapper-plugin"
"memtest86+"
"micro-editor"
"setroubleshoot"
"zram-generator")

solus_packages=(
"cpu-x"
"fastfetch"
"fonts-installer"
"micro"
"nano-syntax-highlighting"
"zram-generator"
)

void_packages=(
"CPU-X"
"fastfetch"
"hplip-gui"
"memtest86+"
"micro"
"zramen"
)

toolbox_packages=(
"btop"
"dos2unix"
"fastfetch"
"git"
"htop"
"inxi"
"micro"
"nano"
"rocm-smi"
"shellcheck"
"smartmontools"
"tealdeer"
"yt-dlp"
)

# List of flatpaks
atomic_flatpaks=(
"com.transmissionbt.Transmission"
"io.github.thetumultuousunicornofdarkness.cpu-x"
"io.mpv.Mpv"
"org.gnome.Boxes"
)

auto_flatpaks=(
"com.bitwarden.desktop"
"com.discordapp.Discord"
"com.spotify.Client"
"io.github.mhogomchungu.media-downloader"
"org.libreoffice.LibreOffice"
"org.mozilla.firefox"
)

manual_flatpaks=(
"org.freedesktop.Platform.ffmpeg-full"
)

# Executes commands based on the operating system
case "$os" in
    "debian")
        # Converts old sources.list format into modern debian.sources format
        sudo apt modernize-sources -y

        # Checks for contrib repository
        if ! grep -Fq "contrib" /etc/apt/sources.list.d/debian.sources; then

            sudo sed -i '/Components:/ s/$/ contrib/' /etc/apt/sources.list.d/debian.sources
            sudo apt-get update
            echo "${green}Enabled: Debian contrib repository ${reset}"

        fi

        # Checks for backports sources file
        if ! [ -f /etc/apt/sources.list.d/debian_backports.sources ]; then

            sudo cp -v "$HOME/Documents/linux_docs/configs/system/debian_backports.sources" /etc/apt/sources.list.d/
            sudo sed -i "/Suites:/ s/version-backports/$(lsb_release -cs)-backports/" /etc/apt/sources.list.d/debian_backports.sources
            sudo apt-get update
            echo "${green}Enabled: Debian backports repository ${reset}"

        fi
        ;;
    "ubuntu")
        # Prevents Debian-specific commands from running on Ubuntu
        ;;
    *)
        case "$os_like" in
            "debian")
                # Converts old sources.list format into modern debian.sources format
                sudo apt modernize-sources -y

                # Checks for contrib repository
                if ! grep -Fq "contrib" /etc/apt/sources.list.d/debian.sources; then

                    sudo sed -i '/Components:/ s/$/ contrib/' /etc/apt/sources.list.d/debian.sources
                    sudo apt-get update
                    echo "${green}Enabled: Debian contrib repository ${reset}"

                fi

                # Checks for backports sources file
                if [ ! -f /etc/apt/sources.list.d/debian_backports.sources ]; then

                    sudo cp -v "$HOME/Documents/linux_docs/configs/system/debian_backports.sources" /etc/apt/sources.list.d/
                    sudo sed -i "/Suites:/ s/version-backports/$(lsb_release -cs)-backports/" /etc/apt/sources.list.d/debian_backports.sources
                    sudo apt-get update

                    echo "${green}Enabled: Debian backports repository ${reset}"

                fi
                ;;
        esac
    ;;
esac

# Checks package manager and installs package(s)
case "$primary_package_manager" in
    "apt")
        sudo apt-get install -y "${universal_packages[@]}" "${debian_packages[@]}" && flatpak_installed=1
        ;;
    "dnf")
        if [ "$os" = "openmandriva" ]; then
            sudo dnf install -y "${universal_packages[@]}" "${openmandriva_packages[@]}" && flatpak_installed=1
        else
            sudo dnf install -y "${universal_packages[@]}" "${fedora_packages[@]}" && flatpak_installed=1
        fi
        ;;
    "eopkg")
        sudo eopkg install -y "${universal_packages[@]}" "${solus_packages[@]}" && flatpak_installed=1
        ;;
    "pacman")
        sudo pacman -S --needed --noconfirm "${universal_packages[@]}" "${arch_packages[@]}" && flatpak_installed=1
        if ! grep -Fq "chaotic" /etc/pacman.conf; then
            sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
            sudo pacman-key --lsign-key 3056513887B78AEB
            sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
            sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
            sudo tee -a /etc/pacman.conf <<-'EOF'
            [chaotic-aur]
                Include = /etc/pacman.d/chaotic-mirrorlist
EOF
            echo "${green}Enabled: Chaotic AUR ${reset}"
        fi

        if [[ "$secondary_package_manager" =~ ^(paru|yay)$ ]]; then
            "$secondary_package_manager" -S "${aur_packages[@]}"
        else
            sudo pacman -S --needed --noconfirm base-devel git makepkg
            git clone https://aur.archlinux.org/paru.git
            cd paru
            makepkg -si --noconfirm
            cd ..
            rm -rf paru
            paru -S "${aur_packages[@]}"
        fi
        ;;
    "xbps")
        sudo xbps-install -Sy "${universal_packages[@]}" "${void_packages[@]}" && flatpak_installed=1
        ;;
    "zypper")
        sudo zypper in -y "${universal_packages[@]}" "${opensuse_packages[@]}" && flatpak_installed=1
        ;;
    "rpm-ostree")
        sudo rpm-ostree install "${atomic_packages[@]}"

        if [ "$toolbox_installed" -eq -1 ]; then
            toolbox create && toolbox run sudo dnf install "${toolbox_packages[@]}"
        fi

        chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/fedora_atomic_mscorefonts_install.sh"
        "$HOME/Documents/linux_docs/scripts/packages/terminal/fedora_atomic_mscorefonts_install.sh"
        ;;
    *)
        echo "${red}Unsupported package manager. ${reset}"
        exit 1
        ;;
esac

# Checks for Fedora and installs Microsoft fonts
if [ "$os" = "fedora" ] || [ "$os_like" = "fedora" ]; then

    if [ "$primary_package_manager" = "dnf" ]; then
        sudo dnf install -y https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
    fi

fi

# Checks for wheel group and adds the current user to it
if getent group wheel > /dev/null 2>&1; then

    sudo usermod -aG wheel "$USER"
    echo "${green}'$USER' added to 'wheel' group. ${reset}"

fi

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for Flatpak
if [ "$flatpak_installed" -eq 1 ]; then

    # Disables Fedora flatpak repositority
    if flatpak remote-list | grep -Fq "fedora"; then
    
        flatpak remote-modify --disable fedora
        echo "${green}Flatpak: Disabled Fedora repository ${reset}"
        
    else
        echo "${yellow}Flatpak: No Fedora repository detected ${reset}"
    fi

    # Adds Flathub repository
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    # Installs package(s)
    flatpak install flathub -y "${auto_flatpaks[@]}"
    flatpak install flathub "${manual_flatpaks[@]}"

    if [ "$primary_package_manager" = "rpm-ostree" ]; then
        flatpak install flathub -y "${atomic_flatpaks[@]}"
    fi
    
    # Checks for Intel GPU
    if echo "$gpu_info" | grep -Fiq "intel"; then
        echo "${green}Detected GPU: Intel ${reset}"

        flatpak install flathub org.freedesktop.Platform.VAAPI.Intel
        
    else
        echo "${yellow}No Intel GPU detected. ${reset}"
    fi
fi

# Checks for package manager then installs package(s)
if [ "$primary_package_manager" = "rpm-ostree" ]; then
    flatpak install flathub -y com.brave.Browser
    
elif [ "$primary_package_manager" = "xbps" ]; then
    flatpak install flathub -y com.brave.Browser
    
else
    curl -fsS https://dl.brave.com/install.sh | sh
fi

# Checks for btrfs partitions
if mount | grep -Fq "type btrfs"; then
    echo "${green}Detected File System: btrfs ${reset}"
    
    # Checks package manager and installs package(s)
    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y btrfs-compsize
            ;;
        "dnf")
            sudo dnf install -y compsize
            ;;
        "eopkg")
            sudo eopkg install -y compsize
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm compsize
            ;;
        "xbps")
            sudo xbps-install -Sy compsize
            ;;
        "zypper")
            sudo zypper in -y compsize
            ;;
        *)
            echo "${red}Unsupported package manager. ${reset}"
            exit 1
            ;;
    esac
    
    # Checks for init system
    if [ "$init_system" = "systemd" ]; then
    
        # Checks package manager and installs package(s)
        case "$primary_package_manager" in
            "apt")
                sudo apt-get install -y btrfsmaintenance
                ;;
            "dnf")
                sudo dnf install -y btrfsmaintenance
                ;;
            "zypper")
                sudo zypper in -y btrfsmaintenance
                ;;
            "rpm-ostree")
                sudo rpm-ostree install btrfsmaintenance
                ;;
            *)
                if [[ "$secondary_package_manager" =~ ^(paru|yay)$ ]]; then
                    "$secondary_package_manager" -S btrfsmaintenance
                fi
                ;;
        esac
        
        # Checks for package unit file and then configures systemd timers and paths
        if systemctl list-unit-files | grep -Fq "btrfsmaintenance"; then

            sudo systemctl disable btrfs-defrag.timer
            sudo systemctl disable btrfs-trim.timer
            sudo systemctl enable btrfs-balance.timer
            sudo systemctl enable btrfs-scrub.timer
            sudo systemctl enable btrfsmaintenance-refresh.path

        fi

    fi
else
    echo "${yellow}No btrfs partitions detected. ${reset}"
fi

# Checks for AMD GPU
if echo "$gpu_info" | grep -Fiq "amd"; then
    echo "${green}Detected GPU: AMD ${reset}"

    case "$primary_package_manager" in
        "apt")
            sudo apt-get install -y rocm-smi
            ;;
        "dnf")
            sudo dnf install -y rocm-smi
            ;;
        "eopkg")
            sudo eopkg install -y rocm-smi
            ;;
        "pacman")
            sudo pacman -S --needed --noconfirm rocm-smi-lib
            ;;
        "xbps")
            sudo xbps-install -Sy ROCm-SMI
            ;;
        "zypper")
            sudo zypper in -y rocm-smi
            ;;
    esac

else
    echo "${yellow}No AMD GPU detected. ${reset}"
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"
mkdir -pv "$HOME/.config/btop"
mkdir -pv "$HOME/.config/fontconfig"
mkdir -pv "$HOME/.config/htop"
mkdir -pv "$HOME/.config/micro"
mkdir -pv "$HOME/.config/mpv"
mkdir -pv "$HOME/.config/nano"
mkdir -pv "$HOME/.var/app/io.mpv.Mpv/config/mpv"
sudo mkdir -pv /etc/sysctl.d/

# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/btop.conf" "$HOME/.config/btop/"
cp -v "$HOME/Documents/linux_docs/configs/packages/fontconfig/fonts.conf" "$HOME/.config/fontconfig/"
cp -v "$HOME/Documents/linux_docs/configs/packages/htoprc" "$HOME/.config/htop/"
cp -v "$HOME/Documents/linux_docs/configs/packages/micro/settings.json" "$HOME/.config/micro/"
cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.config/"
cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"
cp -v "$HOME/Documents/linux_docs/configs/packages/nanorc" "$HOME/.config/nano/"
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/nanorc" /etc/nanorc
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram/99-zram.conf" /etc/sysctl.d/

# Checks for answer
if install_gaming_packages; then

    # Runs script to install gaming packages
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/graphical/gaming_meta_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/graphical/gaming_meta_install.sh"
    
fi

# Checks init system
case "$init_system" in
    "systemd")
        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram/zram-generator.conf" /etc/systemd/

        # Checks host system
        if [ "$host_system" = "laptop" ]; then

            # Changes zram compression algorithm from zstd to lz4
            sudo sed -i 's/zstd/lz4/g' /etc/systemd/zram-generator.conf

            # Edits mpv profile from high quality to fast
            sed -i 's/profile=high-quality/profile=fast/' "$HOME/.config/mpv/mpv.conf"
            sed -i 's/profile=high-quality/profile=fast/' "$HOME/.var/app/io.mpv.Mpv/config/mpv/mpv.conf"
        fi

        sudo systemctl daemon-reload
        sudo systemctl start systemd-zram-setup@zram0.service
        ;;
    "runit")
        if zramctl /dev/zram* >/dev/null 2>&1; then
            sudo zramen toss
        fi

        # Checks host system and adds zram swap device with same size as RAM
        if [ "$host_system" = "laptop" ]; then
            sudo zramen make -a lz4 -s 100

            # Adds command to boot sequence
            if ! grep -Fq "zramen" /etc/rc.local; then
                echo "zramen make -a lz4 -s 100" | sudo tee -a /etc/rc.local
            fi

        elif [ "$host_system" = "desktop" ]; then
            sudo zramen make -a zstd -s 100

            # Adds command to boot sequence
            if ! grep -Fq "zramen" /etc/rc.local; then
                echo "zramen make -a zstd -s 100" | sudo tee -a /etc/rc.local
            fi

        fi
        ;;
    *)
        echo "${red}Unsupported init system: $init_system ${reset}"
        exit 1
        ;;
esac

# Checks host system
if [ "$host_system" = "laptop" ]; then
    preempt_karg="preempt=lazy"

elif [ "$host_system" = "desktop" ]; then
    preempt_karg="preempt=full"
fi

# Checks for package manager or bootloader, then adds kernel argument(s)
case "$primary_package_manager" in
    "rpm-ostree")
        if ! rpm-ostree kargs | grep -Fq "$preempt_karg"; then
            sudo rpm-ostree kargs --append="$preempt_karg"
            echo "${green}'$preempt_karg' added to kernel arguments. ${reset}"

        else
            echo "${green}'$preempt_karg' is already part of kernel arguments. ${reset}"
        fi
        ;;
    *)
        case "$bootloader" in
            "grub")
                if ! grep -Fq "$preempt_karg" /etc/default/grub; then
                    sudo sed -i "s/\(GRUB_CMDLINE_LINUX=\"[^\"]*\)\"/\1 $preempt_karg\"/" /etc/default/grub
                    echo "${green}'$preempt_karg' added to kernel arguments. ${reset}"

                else
                    echo "${green}'$preempt_karg' is already part of kernel arguments. ${reset}"
                fi
                ;;
            "limine")
                if ! grep -Fq "$preempt_karg" /etc/default/limine; then
                    sudo sed -i "/^KERNEL_CMDLINE\[default\\]/ s/\"$/ $preempt_karg\"/" /etc/default/limine
                    echo "${green}'$preempt_karg' added to kernel arguments. ${reset}"

                else
                    echo "${green}'$preempt_karg' is already part of kernel arguments. ${reset}"
                fi
                ;;
        esac
        ;;
esac

# List of packages
gtk_packages=(
"gnome-clocks"
"gnome-weather"
)

qt_packages=(
"kclock"
"kweather" 
)

desktop_flatpaks=(
"com.github.tchx84.Flatseal"
)

# Checks for desktop and package manager and installs package(s)
case "$desktop" in
    "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
        case "$primary_package_manager" in
            "apt")
                sudo apt-get install -y "${qt_packages[@]}" redshift transmission-qt
                ;;
            "dnf")
                sudo dnf install -y "${qt_packages[@]}" redshift transmission-qt
                ;;
            "eopkg")
                sudo eopkg install -y "${qt_packages[@]}" redshift transmission
                ;;
            "pacman")
                sudo pacman -S --needed --noconfirm "${qt_packages[@]}" redshift transmission-qt
                ;;
            "xbps")
                sudo xbps-install -Sy "${qt_packages[@]}" redshift transmission-qt
                ;;
            "zypper")
                sudo zypper in -y "${qt_packages[@]}" redshift transmission-qt
                ;;
        esac

        if [ "$flatpak_installed" -eq 1 ]; then
            flatpak install flathub -y "${desktop_flatpaks[@]}"
        fi
        ;;
    "budgie"|"cosmic"|"deepin"|"pantheon"|"x-cinnamon")
        case "$primary_package_manager" in
            "apt")
                sudo apt-get install -y "${gtk_packages[@]}" transmission-gtk
                ;;
            "dnf")
                sudo dnf install -y "${gtk_packages[@]}" transmission-gtk
                ;;
            "eopkg")
                sudo eopkg install -y "${gtk_packages[@]}" transmission
                ;;
            "pacman")
                sudo pacman -S --needed --noconfirm "${gtk_packages[@]}" transmission-gtk
                ;;
            "xbps")
                sudo xbps-install -Sy "${gtk_packages[@]}" transmission-gtk
                ;;
            "zypper")
                sudo zypper in -y "${gtk_packages[@]}" transmission-gtk
                ;;
        esac

        if [ "$flatpak_installed" -eq 1 ]; then
            flatpak install flathub -y "${desktop_flatpaks[@]}"
        fi
        ;;
    "gnome"|"ubuntu")
        case "$primary_package_manager" in
            "apt")
                sudo apt-get install -y "${gtk_packages[@]}" chrome-gnome-shell gnome-shell-extension-manager transmission-gtk
                ;;
            "dnf")
                sudo dnf install -y "${gtk_packages[@]}" gnome-tweaks transmission-gtk
                ;;
            "eopkg")
                sudo eopkg install -y "${gtk_packages[@]}" redshift transmission
                ;;
            "pacman")
                sudo pacman -S --needed --noconfirm "${gtk_packages[@]}" gnome-tweaks transmission-gtk
                ;;
            "xbps")
                sudo xbps-install -Sy "${gtk_packages[@]}" gnome-tweaks transmission-gtk
                ;;
            "zypper")
                sudo zypper in -y "${gtk_packages[@]}" gnome-tweaks transmission-gtk
                ;;
        esac

        if [ "$flatpak_installed" -eq 1 ]; then
            flatpak install flathub -y "${desktop_flatpaks[@]}" com.mattjakeman.ExtensionManager
        fi

        gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate']"
        echo "${green}Enabled: Variable Refresh Rate. ${reset}"
        ;;
    "lxde"|"mate"|"unity")
        case "$primary_package_manager" in
            "apt")
                sudo apt-get install -y "${gtk_packages[@]}" redshift-gtk transmission-gtk
                ;;
            "dnf")
                sudo dnf install -y "${gtk_packages[@]}" redshift-gtk transmission-gtk
                ;;
            "eopkg")
                sudo eopkg install -y "${gtk_packages[@]}" redshift transmission
                ;;
            "pacman")
                sudo pacman -S --needed --noconfirm "${gtk_packages[@]}" redshift transmission-gtk
                ;;
            "xbps")
                sudo xbps-install -Sy "${gtk_packages[@]}" redshift-gtk transmission-gtk
                ;;
            "zypper")
                sudo zypper in -y "${gtk_packages[@]}" redshift-gtk transmission-gtk
                ;;
        esac

        if [ "$flatpak_installed" -eq 1 ]; then
            flatpak install flathub -y "${desktop_flatpaks[@]}"
        fi
        ;;
    "lxqt")
        case "$primary_package_manager" in
            "apt")
                sudo apt-get install -y "${qt_packages[@]}" redshift-gtk transmission-qt
                ;;
            "dnf")
                sudo dnf install -y "${qt_packages[@]}" redshift-gtk transmission-qt
                ;;
            "eopkg")
                sudo eopkg install -y "${qt_packages[@]}" redshift transmission
                ;;
            "pacman")
                sudo pacman -S --needed --noconfirm "${qt_packages[@]}" redshift transmission-qt
                ;;
            "xbps")
                sudo xbps-install -Sy "${qt_packages[@]}" redshift-gtk transmission-qt
                ;;
            "zypper")
                sudo zypper in -y "${qt_packages[@]}" redshift-gtk transmission-qt
                ;;
        esac

        if [ "$flatpak_installed" -eq 1 ]; then
            flatpak install flathub -y "${desktop_flatpaks[@]}"
        fi
        ;;
    "kde"|"plasma")
        if command -v balooctl6 >/dev/null 2>&1; then
            balooctl6 disable
            echo "${green}Disabled: baloo ${reset}"

        elif command -v balooctl >/dev/null 2>&1; then
            balooctl disable
            echo "${green}Disabled: baloo ${reset}"
        fi

        case "$primary_package_manager" in
            "apt")
                sudo apt-get install -y "${qt_packages[@]}" transmission-qt
                ;;
            "dnf")
                sudo dnf install -y "${qt_packages[@]}" transmission-qt
                ;;
            "eopkg")
                sudo eopkg install -y "${qt_packages[@]}" transmission
                ;;
            "pacman")
                sudo pacman -S --needed --noconfirm "${qt_packages[@]}" transmission-qt
                ;;
            "xbps")
                sudo xbps-install -Sy "${qt_packages[@]}" transmission-qt
                ;;
            "zypper")
                sudo zypper in -y "${qt_packages[@]}" transmission-qt
                ;;
        esac
        ;;

    "xfce")
        case "$primary_package_manager" in
            "apt")
                sudo apt-get install -y "${gtk_packages[@]}" redshift-gtk transmission-gtk xfce4-whiskermenu-plugin
                ;;
            "dnf")
                sudo dnf install -y "${gtk_packages[@]}" redshift-gtk transmission-gtk xfce4-whiskermenu-plugin
                ;;
            "eopkg")
                sudo eopkg install -y "${gtk_packages[@]}" redshift transmission xfce4-whiskermenu-plugin
                ;;
            "pacman")
                sudo pacman -S --needed --noconfirm "${gtk_packages[@]}" redshift transmission-gtk xfce4-whiskermenu-plugin
                ;;
            "xbps")
                sudo xbps-install -Sy "${gtk_packages[@]}" redshift-gtk transmission-gtk xfce4-whiskermenu-plugin
                ;;
            "zypper")
                sudo zypper in -y "${gtk_packages[@]}" redshift-gtk transmission-gtk xfce4-whiskermenu-plugin
                ;;
        esac

        if [ "$flatpak_installed" -eq 1 ]; then
            flatpak install flathub -y "${desktop_flatpaks[@]}"
        fi
        ;;
    *)
        echo "${red}Unsupported desktop. ${reset}"
        exit 1
        ;;
esac

# Checks for package and adds firewall exceptions
if command -v firewall-cmd > /dev/null 2>&1; then

    sudo firewall-cmd --add-interface=wlp8s0 --zone=home
    sudo firewall-cmd --set-default-zone=home
    sudo firewall-cmd --zone=home --add-service=bittorrent-lsd --permanent
    sudo firewall-cmd --zone=home --add-service=dhcp --permanent
    sudo firewall-cmd --zone=home --add-service=dhcpv6 --permanent
    sudo firewall-cmd --zone=home --add-service=dhcpv6-client --permanent
    sudo firewall-cmd --zone=home --add-service=dns --permanent
    sudo firewall-cmd --zone=home --add-service=dns-over-quic --permanent
    sudo firewall-cmd --zone=home --add-service=dns-over-tls --permanent
    sudo firewall-cmd --zone=home --add-service=http --permanent
    sudo firewall-cmd --zone=home --add-service=http3 --permanent
    sudo firewall-cmd --zone=home --add-service=mdns --permanent
    sudo firewall-cmd --zone=home --add-service=samba-client --permanent
    sudo firewall-cmd --zone=home --add-service=slp --permanent
    sudo firewall-cmd --zone=home --add-service=spotify-sync --permanent
    sudo firewall-cmd --zone=home --add-service=ssh --permanent
    sudo firewall-cmd --zone=home --add-service=terraria --permanent
    sudo firewall-cmd --zone=home --add-service=transmission-client --permanent
    sudo firewall-cmd --zone=home --add-port=161-162/tcp --permanent
    sudo firewall-cmd --zone=home --add-port=9100/tcp --permanent
    sudo firewall-cmd --zone=home --add-port=161-162/udp --permanent
    sudo firewall-cmd --zone=home --add-port=9100/udp --permanent
    sudo firewall-cmd --reload
    
fi

# Checks for package
if command -v redshift-gtk > /dev/null 2>&1; then

    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/redshift/redshift.conf" "$HOME/.config/"

    # Define coordinates
    location=$(curl -s "http://ipinfo.io/$(curl -s api.ipify.org)/json")
    latitude=$(echo "$location" | jq -r '.loc' | cut -d',' -f1)
    longitude=$(echo "$location" | jq -r '.loc' | cut -d',' -f2)

    # Adds coordinates to config(s)
    echo "lat=$latitude" >> "$HOME/.config/redshift.conf"
    echo "lon=$longitude" >> "$HOME/.config/redshift.conf"

    # Adds package(s) to autostart
    cp -v "$HOME/Documents/linux_docs/configs/packages/redshift/redshift.desktop" "$HOME/.config/autostart/"
    echo "Exec=redshift-gtk" >> "$HOME/.config/autostart/redshift.desktop"

elif command -v redshift > /dev/null 2>&1; then

    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/redshift/redshift.conf" "$HOME/.config/"

    # Define coordinates
    location=$(curl -s "http://ipinfo.io/$(curl -s api.ipify.org)/json")
    latitude=$(echo "$location" | jq -r '.loc' | cut -d',' -f1)
    longitude=$(echo "$location" | jq -r '.loc' | cut -d',' -f2)

    # Adds coordinates to config(s)
    echo "lat=$latitude" >> "$HOME/.config/redshift.conf"
    echo "lon=$longitude" >> "$HOME/.config/redshift.conf"

    # Adds package(s) to autostart
    cp -v "$HOME/Documents/linux_docs/configs/packages/redshift/redshift.desktop" "$HOME/.config/autostart/"
    echo "Exec=redshift" >> "$HOME/.config/autostart/redshift.desktop"

fi

# Checks for package and copies config(s)
if command -v nmcli > /dev/null 2>&1; then
    echo "${green}Detected: Network Manager ${reset}"

    if [ ! -f /etc/NetworkManager/conf.d/10-permanent-mac-address.conf ]; then

        sudo mkdir -pv /etc/NetworkManager/conf.d
        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/network_manager/10-permanent-mac-address.conf" /etc/NetworkManager/conf.d/

        if command -v systemctl > /dev/null 2>&1; then
            sudo systemctl restart NetworkManager
        fi

    else
        echo "${green}Permanent MAC address is already enabled. ${reset}"
        exit 0
    fi

else
    echo "${yellow}Network Manager not detected. ${reset}"
fi

# Updates bootloader
if [ "$bootloader" = "grub" ]; then
    sudo bash -c "$update_bootloader"
    
elif [ "$bootloader" = "limine" ]; then
    sudo bash -c "$update_bootloader"
fi

# Checks for package manager
if [ "$primary_package_manager" = "pacman" ]; then

    # Removes all cached versions of packages except the latest and one prior version
    sudo paccache -rk1

    # Checks for init system and enables timer to discard unused packages weekly
    if [ "$init_system" = "systemd" ]; then
        sudo systemctl enable --now paccache.timer
    fi
    
fi

# Checks for init system and
if [ "$init_system" = "systemd" ]; then

    # Reloads systemd manager configuration
    sudo systemctl daemon-reload

    # Starts the zram device immediately
    sudo systemctl start systemd-zram-setup@zram0.service
    
fi

# Loads and applies kernel parameter settings
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Checks for answer
if add_autostart_transmission; then

    # Adds package(s) to autostart
    cp -v "$HOME/Documents/linux_docs/configs/packages/transmission.desktop" "$HOME/.config/autostart/"

    if command -v transmission-gtk > /dev/null 2>&1; then
        echo "Exec=transmission-gtk --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"
    
    elif command -v transmission-qt > /dev/null 2>&1; then
        echo "Exec=transmission-qt --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"
    
    elif [ "$flatpak_installed" -eq 1 ] && flatpak list | grep -Fq "com.transmissionbt.Transmission"; then
        echo "Exec=flatpak run com.transmissionbt.Transmission --minimized %U" >> "$HOME/.config/autostart/transmission.desktop"
    fi
    
fi

# Checks for package manager
if [ "$primary_package_manager"  = "dnf" ]; then

    # Adds option(s) to dnf configuration
    if grep -Fq "defaultyes" /etc/dnf/dnf.conf; then

        sudo sed -i '/defaultyes/d' /etc/dnf/dnf.conf
        echo "defaultyes = yes" | sudo tee -a /etc/dnf/dnf.conf

    else
        echo "defaultyes = yes" | sudo tee -a /etc/dnf/dnf.conf
    fi

fi

# Updates or adds custom bashrc settings
if grep -Fq "Custom Settings" "$HOME/.bashrc"; then

    sed -i '/^# Custom Settings/,/^# END/d' "$HOME/.bashrc"
    cat "$HOME/Documents/linux_docs/configs/packages/bashrc" >> "$HOME/.bashrc"
    echo "${green}Updated: $HOME/.bashrc ${reset}"
    
else

    cat "$HOME/Documents/linux_docs/configs/packages/bashrc" >> "$HOME/.bashrc"
    echo "${green}Updated: $HOME/.bashrc ${reset}"
    
fi
    
# Prints a conclusive message
echo "${green}Setup is now complete. ${reset}"
echo "${green}Reboot to apply all changes. ${reset}"
