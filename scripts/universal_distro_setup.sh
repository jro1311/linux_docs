#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Define text colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Define the operating system and convert it to lowercase
if [ -f /etc/os-release ]; then
    . /etc/os-release
    
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
    
    os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
    os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')
    
    echo "${green}Detected Distro (ID): $os ${reset}"
    echo "${green}Detected Distro (ID_LIKE): $os_like ${reset}"
    
else
    echo "${red}Unable to detect the operating system ${reset}"
    exit 1
fi

# Define init system
if ps -p 1 -o comm= | grep -q "systemd"; then
    init_system="systemd"
    echo "${green}Detected Init System: $init_system ${reset}"
    
elif ps -p 1 -o comm= | grep -q "runit"; then
    init_system="runit"
    echo "${green}Detected Init System: $init_system ${reset}"
    
elif ps -p 1 -o comm= | grep -q "sysvinit"; then
    init_system="sysvinit"
    echo "${green}Detected Init System: $init_system ${reset}"
    
elif ps -p 1 -o comm= | grep -q "openrc-init"; then
    init_system="openrc-init"
    echo "${green}Detected Init System: $init_system ${reset}"
    
else
    init_system="unknown"
fi

# Define bootloader
if command -v update-grub > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="update-grub"
    echo "${green}Detected Bootloader: $bootloader ${reset}"
    
elif command -v grub2-mkconfig > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub2-mkconfig -o /boot/grub2/grub.cfg"
    echo "${green}Detected Bootloader: $bootloader ${reset}"
    
elif command -v grub-mkconfig > /dev/null 2>&1; then
    bootloader="grub"
    update_bootloader="grub-mkconfig -o /boot/grub/grub.cfg"
    echo "${green}Detected Bootloader: $bootloader ${reset}"
    
elif command -v limine-update > /dev/null 2>&1; then
    bootloader="limine"
    update_bootloader="limine-update"
    echo "${green}Detected Bootloader: $bootloader ${reset}"
    
elif find /boot/efi/EFI -name "*systemd-boot*.efi" > /dev/null 2>&1; then
    bootloader="systemd-boot"
    update_bootloader="bootctl update"
    echo "${green}Detected Bootloader: $bootloader ${reset}"
    
else
    bootloader="unknown"
    update_bootloader="unknown"
fi

# Define primary package manager
if command -v apt > /dev/null 2>&1; then
    primary_package_manager="apt"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v dnf > /dev/null 2>&1; then
    primary_package_manager="dnf"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v pacman > /dev/null 2>&1; then
    primary_package_manager="pacman"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v xbps-install > /dev/null 2>&1; then
    primary_package_manager="xbps"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v zypper > /dev/null 2>&1; then
    primary_package_manager="zypper"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
elif command -v rpm-ostree > /dev/null 2>&1; then
    primary_package_manager="rpm-ostree"
    echo "${green}Detected Package Manager: $primary_package_manager ${reset}"
    
else
    primary_package_manager="unknown"
fi

# Define AUR package manager
if command -v paru > /dev/null 2>&1; then
    aur_package_manager="paru"
    echo "Detected Package Manger: $aur_package_manager"

elif command -v yay > /dev/null 2>&1; then
    aur_package_manager="yay"
    echo "Detected Package Manger: $aur_package_manager"
    
else
    aur_package_manager="unknown"
fi

# Checks for package manager and installs package(s)
if [ "$primary_package_manager" = "apt" ]; then
    sudo apt-get update && sudo apt-get install -y nala
fi

# Checks for package manager and removes package(s)
if [ "$primary_package_manager" = "apt" ]; then

    if command -v libreoffice > /dev/null 2>&1; then
        sudo nala remove -y libreoffice*
    fi
    
elif [ "$primary_package_manager" = "dnf" ]; then

    # Checks for OpenMandriva
    if [ "$os" = "openmandriva" ]; then
        if command -v chromium > /dev/null 2>&1; then
            sudo dnf remove -y chromium
        fi
    fi
    
    if command -v libreoffice > /dev/null 2>&1; then
        sudo dnf remove -y libreoffice*
    fi
    
elif [ "$primary_package_manager" = "zypper" ]; then

    if command -v vlc > /dev/null 2>&1; then
        sudo zypper rm --clean-deps -y vlc
    fi
    
    if command -v libreoffice > /dev/null 2>&1; then
        sudo zypper rm --clean-deps -y libreoffice*
    fi
    
elif [ "$primary_package_manager" = "rpm-ostree" ]; then

    if command -v firefox > /dev/null 2>&1; then
        sudo rpm-ostree override remove firefox firefox-langpacks
    fi
    
    if command -v libreoffice > /dev/null 2>&1; then
        sudo rpm-ostree override remove libreoffice
    fi
fi

# Package manager array
managers=(apt dnf pacman paru yay xbps zypper flatpak snap rpm-ostree)

# Loops through package managers and upgrades system
for manager in "${managers[@]}"; do
    case "$manager" in
        "apt")
            if command -v nala > /dev/null 2>&1; then
                sudo nala upgrade -y
                
            elif command -v apt > /dev/null 2>&1; then
                sudo apt-get update && sudo apt-get -y upgrade
            fi
            ;;
        "dnf")
            if command -v dnf > /dev/null 2>&1; then
                sudo dnf -y upgrade
            fi
            ;;
        "pacman")
            if command -v pacman > /dev/null 2>&1; then
                sudo pacman -Syu --noconfirm
            fi
            ;;
        "paru")
            if command -v paru > /dev/null 2>&1; then
                paru -Syu --noconfirm
            fi
            ;;
        "yay")
            if command -v yay > /dev/null 2>&1; then
                yay -Syu --noconfirm
            fi
            ;;
        "xbps")
            if command -v xbps-remove > /dev/null 2>&1; then
                sudo xbps-install -Suy xbps && sudo xbps-install -uy
            fi
            ;;
        "zypper")
            if command -v zypper > /dev/null 2>&1; then
            
                # Checks for openSUSE distro
                if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
                    sudo zypper ref && sudo zypper dup -y
                elif [ "$os" = "opensuse-leap" ]; then
                    sudo zypper ref && sudo zypper up -y
                fi
                
            fi
            ;;
        "flatpak")
            if command -v flatpak > /dev/null 2>&1; then
                flatpak update -y
            fi
            ;;
        "snap")
            if command -v snap > /dev/null 2>&1; then
                sudo snap refresh
            fi
            ;;
        "rpm-ostree")
            if command -v rpm-ostree > /dev/null 2>&1; then
                sudo rpm-ostree upgrade
            fi
            ;;
    esac
done

# Function for user input
get_answer1() {
    while true; do
        read -r -p "${green}Install multimedia codecs (Y/n)? ${reset}" answer1
        answer1="${answer1:-y}"
        case "$answer1" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Enter a 'y' or 'n'";;
        esac
    done
}

# Checks for answer
if get_answer1; then

    # Checks for package manager and runs script to install codecs
    if [ "$primary_package_manager" = "apt" ]; then
        chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_debian_install.sh"
        "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_debian_install.sh"

    elif [ "$primary_package_manager" = "dnf" ]; then
    
        # Checks for OpenMandriva
        if [ "$os" = "openmandriva" ]; then
            chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_openmandriva_install.sh"
            "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_openmandriva_install.sh"
            
        else
            chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_fedora_install.sh"
            "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_fedora_install.sh"
        fi

    elif [ "$primary_package_manager" = "xbps" ]; then
        chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_void_install.sh"
        "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_void_install.sh"

    elif [ "$primary_package_manager" = "zypper" ]; then
        chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_opensuse_install.sh"
        "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_opensuse_install.sh"
    fi

else
    echo "Skipping installation of multimedia codecs..."
fi

# List of universal packages
universal_packages=(
"btop"
"curl"
"dos2unix"
"flatpak"
"fontconfig"
"fzf"
"git"
"gnome-disk-utility"
"gsmartcontrol"
"hplip"
"htop"
"inxi"
"memtest86+"
"nano"
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
"firefox"
"micro"
"zram-generator"
)

aur_packages=(
"linux-lts"
"nano-syntax-highlighting"
"ttf-ms-win11-auto"
)

debian_packages=(
"cpu-x"
"micro"
"neofetch"
"systemd-zram-generator"
"ttf-mscorefonts-installer"
)

atomic_packages=(
"gnome-disk-utility"
)

fedora_packages=(
"cabextract"
"cpu-x"
"fastfetch"
"firefox"
"google-noto-sans-jp-fonts"
"google-noto-sans-kr-fonts"
"micro"
"xorg-x11-font-utils"
"zram-generator"
)

openmandriva_packages=(
"cpu-x"
"fastfetch"
"firefox"
"fonts-ttf-japanese"
"fonts-ttf-korean"
"micro"
"zram-generator"
)

opensuse_packages=(
"cpu-x"
"fastfetch"
"fetchmsttfonts"
"grub2-snapper-plugin"
"micro-editor"
"MozillaFirefox"
"setroubleshoot"
"zram-generator")

void_packages=(
"CPU-X"
"fastfetch"
"firefox"
"micro"
"zramen"
)

toolbox_packages=(
"btop"
"dos2unix"
"fastfetch"
"fzf"
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
"org.mozilla.firefox"
)

auto_flatpaks=(
"com.bitwarden.desktop"
"com.spotify.Client"
"dev.vencord.Vesktop"
"org.libreoffice.LibreOffice"
)

manual_flatpaks=(
"org.freedesktop.Platform.ffmpeg-full"
)

# Executes commands based on the operating system
case "$os" in
    "debian")
        # Checks for Debian backports repository
        if ! grep -Fq 'backports' /etc/apt/sources.list; then
            echo "deb http://deb.debian.org/debian $(lsb_release -cs)-backports main" | sudo tee -a /etc/apt/sources.list && sudo nala update
            echo "${green}Enabled Debian backports repository ${reset}"
        fi
        
        # Installs package(s)
        sudo nala install -y firefox-esr
        ;;
    "ubuntu")
        # Installs package(s)
        sudo nala install -y firefox
        ;;
    *)
        case "$os_like" in
            "debian")
                # Checks for Debian backports repository
                if ! grep -Fq 'backports' /etc/apt/sources.list; then
                    echo "deb http://deb.debian.org/debian $(lsb_release -cs)-backports main" | sudo tee -a /etc/apt/sources.list && sudo nala update
                    echo "${green}Enabled Debian backports repository ${reset}"
                fi
                
                # Installs package(s)
                sudo nala install -y firefox-esr
                ;;
            "ubuntu"|"ubuntu debian")
                # Installs package(s)
                sudo nala install -y firefox
                ;;
        esac
    ;;
esac

# Checks for package manager and installs packages
if [ "$primary_package_manager" = "apt" ]; then
    sudo nala install -y "${universal_packages[@]}" "${debian_packages[@]}"

elif [ "$primary_package_manager" = "dnf" ]; then
    sudo dnf install -y "${universal_packages[@]}" "${fedora_packages[@]}"
    
    # Checks for OpenMandriva
    if [ "$os" = "openmandriva" ]; then
        sudo dnf install -y "${universal_packages[@]}" "${openmandriva_packages[@]}"
    else
        sudo dnf install -y "${universal_packages[@]}" "${fedora_packages[@]}"
    fi

elif [ "$primary_package_manager" = "pacman" ]; then
    sudo pacman -S --needed --noconfirm "${universal_packages[@]}" "${arch_packages[@]}"
    
    # Checks for Chaotic AUR
    if ! grep -q 'chaotic' /etc/pacman.conf; then
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
        sudo tee -a /etc/pacman.conf <<-'EOF'
        [chaotic-aur]
            Include = /etc/pacman.d/chaotic-mirrorlist

EOF
        echo "${green}Added Chaotic AUR repository ${reset}"
    fi
    
    # Checks for AUR helper
    if [ "$aur_package_manager" != "unknown" ]; then
        "$aur_package_manager" -S "${aur_packages[@]}"
    else
        sudo pacman -S --needed --noconfirm base-devel git makepkg
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ..
        rm -rf paru
        paru -S "${aur_packages[@]}"
    fi

elif [ "$primary_package_manager" = "xbps" ]; then
    sudo xbps-install -Sy "${universal_packages[@]}" "${void_packages[@]}"

elif [ "$primary_package_manager" = "zypper" ]; then
    sudo zypper in -y "${universal_packages[@]}" "${opensuse_packages[@]}"

elif [ "$primary_package_manager" = "rpm-ostree" ]; then
    sudo rpm-ostree install "${atomic_packages[@]}"
    flatpak install flathub -y "${atomic_flatpaks[@]}"
    
    # Creates a toolbox container and installs packages inside of it
    toolbox create && toolbox run sudo dnf install "${toolbox_packages[@]}"

    # Installs Microsoft fonts
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/fedora_atomic_mscorefonts_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/fedora_atomic_mscorefonts_install.sh"

else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Checks for Fedora and installs Microsoft fonts
if [ "$os" = "fedora" ] || [ "$os_like" = "fedora" ]; then
    sudo dnf install -y https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
fi

# Define secondary package manager
if command -v flatpak > /dev/null 2>&1; then
    secondary_package_manager="flatpak"
    echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
    
else
    secondary_package_manager="unknown"
fi

# Checks for wheel group and adds the current user to it
if getent group wheel > /dev/null 2>&1; then
    sudo usermod -aG wheel "$USER"
    echo "${green}Added $USER to wheel group ${reset}"
else
    echo "${yellow}wheel group does not exist ${reset}"
fi

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for flatpak
if [ "$secondary_package_manager" = "flatpak" ]; then

    # Disables Fedora flatpak repositority
    if flatpak remote-list | grep -q "fedora"; then
        flatpak remote-modify --disable fedora
        echo "${green}Disabled Fedora flatpak repository ${reset}"
    else
        echo "${yellow}No Fedora flatpak repository detected ${reset}"
    fi

    # Adds Flathub repository
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    # Installs package(s)
    flatpak install flathub -y "${auto_flatpaks[@]}"
    flatpak install flathub "${manual_flatpaks[@]}"
    
    # Checks for Intel GPU
    if echo "$gpu_info" | grep -Fiq "intel"; then
        echo "${green}Detected GPU: Intel ${reset}"
        
        # Installs package(s)
        flatpak install flathub org.freedesktop.Platform.VAAPI.Intel
        
    else
        echo "${yellow}No Intel GPU detected ${reset}"
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
if mount | grep -q "type btrfs"; then
    echo "${green}Detected File System: btrfs ${reset}"
    
    # Checks for package manager and installs package(s)
    if [ "$primary_package_manager" = "apt" ]; then
        sudo nala install -y btrfs-compsize
        
    elif [ "$primary_package_manager" = "dnf" ]; then
        sudo dnf install -y compsize
        
    elif [ "$primary_package_manager" = "pacman" ]; then
        sudo pacman -S --needed --noconfirm compsize
        
    elif [ "$primary_package_manager" = "xbps" ]; then
        sudo xbps-install -Sy compsize
        
    elif [ "$primary_package_manager" = "zypper" ]; then
        sudo zypper in -y compsize
    fi
    
    # Checks for init system
    if [ "$init_system" = "systemd" ]; then
    
        # Checks for package manager and installs package(s)
        if [ "$primary_package_manager" = "apt" ]; then
            sudo nala install -y btrfsmaintenance
        
        elif [ "$primary_package_manager" = "dnf" ]; then
            sudo dnf install -y btrfsmaintenance
        
        elif [ "$aur_package_manager" ]; then
            "$aur_package_manager" -S btrfsmaintenance
            
        elif [ "$primary_package_manager" = "zypper" ]; then
            sudo zypper in -y btrfsmaintenance
        
        elif [ "$primary_package_manager" = "rpm-ostree" ]; then
            sudo rpm-ostree install btrfsmaintenance
        fi
        
        # Configures system timer(s)
        sudo systemctl disable btrfs-defrag.timer
        sudo systemctl disable btrfs-trim.timer
        sudo systemctl enable btrfs-balance.timer
        sudo systemctl enable btrfs-scrub.timer
        sudo systemctl enable btrfsmaintenance-refresh.path
    fi
else
    echo "${yellow}No btrfs partitions detected ${reset}"
fi

# Checks for AMD GPU
if echo "$gpu_info" | grep -Fiq "amd"; then
    echo "${green}Detected GPU: AMD ${reset}"
    
    # Checks for package manager and installs package(s)
    if [ "$primary_package_manager" = "apt" ]; then
        sudo nala install -y rocm-smi
        
    elif [ "$primary_package_manager" = "dnf" ]; then
        sudo dnf install -y rocm-smi
        
    elif [ "$primary_package_manager" = "pacman" ]; then
        sudo pacman -S --needed --noconfirm rocm-smi-lib
        
    elif [ "$primary_package_manager" = "xbps" ]; then
        sudo xbps-install -Sy ROCm-SMI
        
    elif [ "$primary_package_manager" = "zypper" ]; then
        sudo zypper in -y rocm-smi
    fi
    
else
    echo "${yellow}No AMD GPU detected ${reset}"
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
cp -v "$HOME/Documents/linux_docs/configs/packages/fonts.conf" "$HOME/.config/fontconfig/"
cp -v "$HOME/Documents/linux_docs/configs/packages/htoprc" "$HOME/.config/htop/"
cp -v "$HOME/Documents/linux_docs/configs/packages/micro/settings.json" "$HOME/.config/micro/"
cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.config/"
cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"
cp -v "$HOME/Documents/linux_docs/configs/packages/nanorc" "$HOME/.config/nano/"
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/nanorc" /etc/nanorc
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/99-zram.conf" /etc/sysctl.d/

# Function for user input
get_answer2() {
    while true; do
        read -r -p "${green}Install gaming packages (Y/n)? ${reset}" answer2
        answer2="${answer2:-y}"
        case "$answer2" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Enter a 'y' or 'n'";;
        esac
    done
}

# Checks for answer
if get_answer2; then

    # Runs script to install gaming packages
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/graphical/gaming_meta_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/graphical/gaming_meta_install.sh"
    
else
    echo "Skipping installation of gaming packages..."
fi

# Enables nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Detect batteries
batteries=(/sys/class/power_supply/BAT*)

# Checks for battery
if (( ${#batteries[@]} )); then
    echo "${green}Detected System: Laptop ${reset}"
    
    # Edits htop to include battery status
    sed -i '/^column_meters_1/s/$/ Battery/' "$HOME/.config/htop/htoprc"
    
    # Edits mpv profile from high quality to fast
    sed -i 's/profile=high-quality/profile=fast/' "$HOME/.config/mpv/mpv.conf"
    sed -i 's/profile=high-quality/profile=fast/' "$HOME/.var/app/io.mpv.Mpv/config/mpv/mpv.conf"

    # Checks for init system
    if [ "$init_system" = "systemd" ]; then
    
        # Copies config(s)
        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram-generator.conf" /etc/systemd/
        
        # Edits compression algorithm from zstd to lz4
        sudo sed -i 's/lz4/zstd/g' /etc/systemd/zram_generator.conf
        
    elif [ "$init_system" = "runit" ]; then
        
        # Removes old zram swap devices if present
        if zramctl | grep -Fq "zram"; then
            sudo zramen toss
        fi
    
        # Makes zram swap device
        sudo zramen make -a lz4 -s 100
        
        # Runs command at startup
        echo "zramen -a lz4 -s 100" | sudo tee -a /etc/rc.local
    fi

    # Checks for package manager or bootloader, then adds kernel argument(s)
    if [ "$primary_package_manager" = "rpm-ostree" ]; then
        if ! rpm-ostree kargs | grep -Fq "preempt=lazy"; then
        
            rpm-ostree kargs --append=preempt=lazy
            echo "${green}Added preempt=lazy to kernel arguments ${reset}"
            
        else
            echo "${green}preempt=lazy already part of kernel arguments ${reset}"
        fi
        
    elif [ "$bootloader" = "grub" ]; then
        if ! grep -Fq "preempt=lazy" /etc/default/grub; then
        
            sudo sed -i 's/\(GRUB_CMDLINE_LINUX="[^"]*\)"/\1 preempt=lazy"/' /etc/default/grub
            echo "${green}Added preempt=lazy to kernel arguments ${reset}"
            
        else
            echo "${green}preempt=lazy already part of kernel arguments ${reset}"
        fi
        
    elif [ "$bootloader" = "limine" ]; then
        if ! grep -Fq "preempt=lazy" /etc/default/limine; then
        
            sudo sed -i 's/\(KERNEL_CMDLINE[default]+="[^"]*\)"/\1 preempt=lazy"/' /etc/default/limine
            echo "${green}Added preempt=lazy to kernel arguments ${reset}"
            
        else
            echo "${green}preempt=lazy already part of kernel arguments ${reset}"
        fi
    fi
else
    echo "${green}Detected System: Desktop ${reset}"
    
    # Checks for init system
    if [ "$init_system" = "systemd" ]; then
    
        # Copies config(s)
        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram-generator.conf" /etc/systemd/
        
    elif [ "$init_system" = "runit" ]; then
    
        # Removes old zram swap devices if present
        if zramctl | grep -Fq "zram"; then
            sudo zramen toss
        fi
    
        # Makes zram swap device
        sudo zramen make -a zstd -s 100
        
        # Runs command at startup
        echo "zramen -a zstd -s 100" | sudo tee -a /etc/rc.local
    fi
    
    # Checks for package manager or bootloader, then adds kernel argument(s)
    if [ "$primary_package_manager" = "rpm-ostree" ]; then
        if ! rpm-ostree kargs | grep -Fq "preempt=full"; then
        
            rpm-ostree kargs --append=preempt=full
            echo "${green}Added preempt=full to kernel arguments ${reset}"
            
        else
            echo "${green}preempt=full already part of kernel arguments ${reset}"
        fi
        
    elif [ "$bootloader" = "grub" ]; then
        if ! grep -Fq "preempt=full" /etc/default/grub; then
        
            sudo sed -i 's/\(GRUB_CMDLINE_LINUX="[^"]*\)"/\1 preempt=full"/' /etc/default/grub
            echo "${green}Added preempt=full to kernel arguments ${reset}"
            
        else
            echo "${green}preempt=full already part of kernel arguments ${reset}"
        fi
        
    elif [ "$bootloader" = "limine" ]; then
        if ! grep -Fq "preempt=full" /etc/default/limine; then
        
            sudo sed -i 's/\(KERNEL_CMDLINE[default]+="[^"]*\)"/\1 preempt=full"/' /etc/default/limine
            echo "${green}Added preempt=full to kernel arguments ${reset}"
            
        else
            echo "${green}preempt=full already part of kernel arguments ${reset}"
        fi
    fi
fi

# Define the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')
echo "${green}Detected Desktop: $desktop ${reset}"

# List of packages

gtk_packages=(
"gnome-clocks"
"gnome-weather"
"transmission-gtk"
)

qt_packages=(
"kclock"
"kweather" 
"transmission-qt"
)

desktop_flatpaks=(
"com.github.tchx84.Flatseal"
)

# Executes commands based on the desktop
case "$desktop" in
    "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
        # Checks for package manager and installs package(s)
        if [ "$primary_package_manager" = "apt" ]; then
            sudo nala install -y "${qt_packages[@]}" redshift
        
        elif [ "$primary_package_manager" = "dnf" ]; then
            sudo dnf install -y "${qt_packages[@]}" redshift
        
        elif [ "$primary_package_manager" = "pacman" ]; then
            sudo pacman -S --needed --noconfirm "${qt_packages[@]}" redshift
        
        elif [ "$primary_package_manager" = "xbps" ]; then
            sudo xbps-install -Sy "${qt_packages[@]}" redshift
        
        elif [ "$primary_package_manager" = "zypper" ]; then
            sudo zypper in -y "${qt_packages[@]}" redshift
        fi
        
        if [ "$secondary_package_manager" = "flatpak" ]; then
            flatpak install flathub -y "${desktop_flatpaks[@]}"
        fi
        ;;
    "budgie"|"cosmic"|"deepin"|"pantheon"|"x-cinnamon")
        # Checks for package manager and installs package(s)
        if [ "$primary_package_manager" = "apt" ]; then
            sudo nala install -y "${gtk_packages[@]}"
        
        elif [ "$primary_package_manager" = "dnf" ]; then
            sudo dnf install -y "${gtk_packages[@]}"
        
        elif [ "$primary_package_manager" = "pacman" ]; then
            sudo pacman -S --needed --noconfirm "${gtk_packages[@]}"
        
        elif [ "$primary_package_manager" = "xbps" ]; then
            sudo xbps-install -Sy "${gtk_packages[@]}"
        
        elif [ "$primary_package_manager" = "zypper" ]; then
            sudo zypper in -y "${gtk_packages[@]}"
        fi
    
        if [ "$secondary_package_manager" = "flatpak" ]; then
            flatpak install flathub -y "${desktop_flatpaks[@]}"
        fi
        ;;
    "gnome")
        # Checks for package manager and installs package(s)
        if [ "$primary_package_manager" = "apt" ]; then
            sudo nala install -y "${gtk_packages[@]}" chrome-gnome-shell gnome-shell-extension-manager
        
        elif [ "$primary_package_manager" = "dnf" ]; then
            sudo dnf install -y "${gtk_packages[@]}" gnome-tweaks
        
        elif [ "$primary_package_manager" = "pacman" ]; then
            sudo pacman -S --needed --noconfirm "${gtk_packages[@]}" gnome-tweaks
        
        elif [ "$primary_package_manager" = "xbps" ]; then
            sudo xbps-install -Sy "${gtk_packages[@]}" gnome-tweaks
        
        elif [ "$primary_package_manager" = "zypper" ]; then
            sudo zypper in -y "${gtk_packages[@]}" gnome-tweaks
        fi
            
        if [ "$secondary_package_manager" = "flatpak" ]; then
            flatpak install flathub -y "${desktop_flatpaks[@]}" com.mattjakeman.ExtensionManager
        fi

        # Enables experimental variable refresh rate support
        gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate']"
        echo "${green}Enabled option for experimental Variable Refresh Rate ${reset}"
        ;;
    "lxde"|"mate"|"unity")
        # Checks for package manager and installs package(s)
        if [ "$primary_package_manager" = "apt" ]; then
            sudo nala install -y "${gtk_packages[@]}" redshift-gtk
        
        elif [ "$primary_package_manager" = "dnf" ]; then
            sudo dnf install -y "${gtk_packages[@]}" redshift-gtk
        
        elif [ "$primary_package_manager" = "pacman" ]; then
            sudo pacman -S --needed --noconfirm "${gtk_packages[@]}" redshift
        
        elif [ "$primary_package_manager" = "xbps" ]; then
            sudo xbps-install -Sy "${gtk_packages[@]}" redshift-gtk
        
        elif [ "$primary_package_manager" = "zypper" ]; then
            sudo zypper in -y "${gtk_packages[@]}" redshift-gtk
        fi
            
        if [ "$secondary_package_manager" = "flatpak" ]; then
            flatpak install flathub -y "${desktop_flatpaks[@]}"
        fi
        ;;
    "lxqt")
        # Checks for package manager and installs package(s)
        if [ "$primary_package_manager" = "apt" ]; then
            sudo nala install -y "${qt_packages[@]}" redshift-gtk
        
        elif [ "$primary_package_manager" = "dnf" ]; then
            sudo dnf install -y "${qt_packages[@]}" redshift-gtk
        
        elif [ "$primary_package_manager" = "pacman" ]; then
            sudo pacman -S --needed --noconfirm "${qt_packages[@]}" redshift
        
        elif [ "$primary_package_manager" = "xbps" ]; then
            sudo xbps-install -Sy "${qt_packages[@]}" redshift-gtk
        
        elif [ "$primary_package_manager" = "zypper" ]; then
            sudo zypper in -y "${qt_packages[@]}" redshift-gtk
        fi
            
        if [ "$secondary_package_manager" = "flatpak" ]; then
            flatpak install flathub -y "${desktop_flatpaks[@]}"
        fi
        ;;
    "plasma")
        # Disables baloo
        if command -v balooctl6 >/dev/null 2>&1; then
            balooctl6 disable
            echo "${green}baloo disabled ${reset}"
        elif command -v balooctl >/dev/null 2>&1; then
            balooctl disable
            echo "${green}baloo disabled ${reset}"
        fi
        
        # Checks for package manager and installs package(s)
        if [ "$primary_package_manager" = "apt" ]; then
            sudo nala install -y "${qt_packages[@]}"
        
        elif [ "$primary_package_manager" = "dnf" ]; then
            sudo dnf install -y "${qt_packages[@]}"
        
        elif [ "$primary_package_manager" = "pacman" ]; then
            sudo pacman -S --needed --noconfirm "${qt_packages[@]}"
        
        elif [ "$primary_package_manager" = "xbps" ]; then
            sudo xbps-install -Sy "${qt_packages[@]}"
        
        elif [ "$primary_package_manager" = "zypper" ]; then
            sudo zypper in -y "${qt_packages[@]}"
        fi
        ;;
    "xfce")
        # Checks for package manager and installs package(s)
        if [ "$primary_package_manager" = "apt" ]; then
            sudo nala install -y "${gtk_packages[@]}" redshift-gtk xfce4-whiskermenu-plugin
        
        elif [ "$primary_package_manager" = "dnf" ]; then
            sudo dnf install -y "${gtk_packages[@]}" redshift-gtk xfce4-whiskermenu-plugin
        
        elif [ "$primary_package_manager" = "pacman" ]; then
            sudo pacman -S --needed --noconfirm "${gtk_packages[@]}" redshift xfce4-whiskermenu-plugin
        
        elif [ "$primary_package_manager" = "xbps" ]; then
            sudo xbps-install -Sy "${gtk_packages[@]}" redshift-gtk xfce4-whiskermenu-plugin
        
        elif [ "$primary_package_manager" = "zypper" ]; then
            sudo zypper in -y "${gtk_packages[@]}" redshift-gtk xfce4-whiskermenu-plugin
        fi
            
        if [ "$secondary_package_manager" = "flatpak" ]; then
            flatpak install flathub -y "${desktop_flatpaks[@]}"
        fi
        ;;
    *)
        echo "${red}Unsupported desktop ${reset}"
        exit 1
        ;;
        
esac

# Checks for package and adds firewall exceptions
if command -v firewall-cmd > /dev/null 2>&1; then
    sudo firewall-cmd --add-interface=wlp8s0 --zone=home --permanent
    sudo firewall-cmd --set-default-zone=home --permanent
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

# Updates bootloader
if [ "$bootloader" = "grub" ]; then
    sudo "$update_bootloader"
    
elif [ "$bootloader" = "limine" ]; then
    sudo "$update_bootloader"
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
    sudo systemctl start /dev/zram0
fi

# Loads and applies kernel parameter settings
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Checks for package
if command -v redshift > /dev/null 2>&1; then

    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"
        
    # Adds package(s) to autostart
    cp -v /usr/share/applications/redshift*.desktop "$HOME/.config/autostart/"
    
fi
    
# Checks for package manager and adds package(s) to autostart
if [ "$primary_package_manager" = "rpm-ostree" ]; then
    cp -v /var/lib/flatpak/exports/share/applications/com.transmissionbt.Transmission.desktop "$HOME/.config/autostart/"
else
    cp -v /usr/share/applications/transmission*.desktop "$HOME/.config/autostart/"
fi

# Updates or adds custom bashrc settings
if grep -Fq "Custom Settings" "$HOME/.bashrc"; then

    sed -i '/^# Custom Settings/,${/^# Custom Settings/d; d;}' "$HOME/.bashrc"
    cat "$HOME/Documents/linux_docs/configs/packages/bashrc" >> "$HOME/.bashrc"
    echo "${green}Updated custom bashrc settings ${reset}"
    
else

    cat "$HOME/Documents/linux_docs/configs/packages/bashrc" >> "$HOME/.bashrc"
    echo "${green}Added custom bashrc settings ${reset}"
    
fi
    
# Prints a conclusive message
echo "${green}Setup is now complete${reset}"
echo "${green}Reboot to apply all changes${reset}"
