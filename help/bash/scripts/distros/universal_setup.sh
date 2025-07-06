#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Text formatting
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Detect the operating system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "${red}Unable to detect the operating system ${reset}"
    exit 1
fi

# Convert operating system to lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Detect init
if ps -p 1 -o comm= | grep -q "systemd"; then
    init_system="systemd"
    
elif ps -p 1 -o comm= | grep -q "runit"; then
    init_system="runit"
    
elif ps -p 1 -o comm= | grep -q "sysvinit"; then
    init_system="sysvinit"
    
elif ps -p 1 -o comm= | grep -q "openrc-init"; then
    init_system="openrc-init"
    
else
    init_system="unknown"
fi

# Detect main package manager
if command -v apt > /dev/null 2>&1; then
    main_package_manager="apt"
     
elif command -v dnf > /dev/null 2>&1; then
    main_package_manager="dnf"
    
elif command -v pacman > /dev/null 2>&1; then
    main_package_manager="pacman"
    
elif command -v xbps-install > /dev/null 2>&1; then
    main_package_manager="xbps"
    
elif command -v zypper > /dev/null 2>&1; then
    main_package_manager="zypper"

elif command -v rpm-ostree > /dev/null 2>&1; then
    main_package_manager="rpm-ostree"

else
    main_package_manager="unknown"
fi

# Detect AUR package manager
if command -v paru > /dev/null 2>&1; then
    aur_package_manager="paru"

elif command -v yay > /dev/null 2>&1; then
    aur_package_manager="yay"
fi

# Checks for package manager and installs package(s)
if [ "$main_package_manager" = "apt" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo apt-get update && sudo apt-get install -y nala
fi

# Checks for package manager and removes package(s)
if [ "$main_package_manager" = "apt" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo nala remove -y libreoffice*
    
elif [ "$main_package_manager" = "dnf" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    if [ "$os" = "openmandriva" ]; then
        echo "${green}Detected Distro (ID): $os ${reset}"
        sudo dnf remove -y chromium
    fi
    sudo dnf remove -y libreoffice*
    
elif [ "$main_package_manager" = "zypper" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo zypper rm --clean-deps -y vlc
    
elif [ "$main_package_manager" = "rpm-ostree" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    rpm-ostree override remove firefox firefox-langpacks
fi

# Package managers
managers=(apt dnf pacman paru yay xbps zypper flatpak snap rpm-ostree)

# Loops through package managers
for manager in "${managers[@]}"; do
    case "$manager" in
        "apt")
            if command -v nala > /dev/null 2>&1; then
                echo "${green}Detected Package Manager: $manager ${reset}"
                sudo nala upgrade -y
            elif command -v apt > /dev/null 2>&1; then
                echo "${green}Detected Package Manager: $manager ${reset}"
                sudo apt-get update && sudo apt-get -y upgrade
            fi
            ;;
        "dnf")
            if command -v dnf > /dev/null 2>&1; then
                echo "${green}Detected Package Manager: $manager ${reset}"
                sudo dnf -y upgrade
            fi
            ;;
        "pacman")
            if command -v pacman > /dev/null 2>&1; then
                echo "${green}Detected Package Manager: $manager ${reset}"
                sudo pacman -Syu --noconfirm
            fi
            ;;
        "paru")
            if command -v paru > /dev/null 2>&1; then
                echo "${green}Detected Package Manager: $manager ${reset}"
                paru -Syu --noconfirm
            fi
            ;;
        "yay")
            if command -v yay > /dev/null 2>&1; then
                echo "${green}Detected Package Manager: $manager ${reset}"
                yay -Syu --noconfirm
            fi
            ;;
        "xbps")
            if command -v xbps-remove > /dev/null 2>&1; then
                echo "${green}Detected Package Manager: $manager ${reset}"
                sudo xbps-install -Suy xbps && sudo xbps-install -uy
            fi
            ;;
        "zypper")
            if command -v zypper > /dev/null 2>&1; then
                echo "${green}Detected Package Manager: $manager ${reset}"
                echo "${green}Detected Distro (ID): $os ${reset}"
                if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
                    sudo zypper ref && sudo zypper dup -y
                elif [ "$os" = "opensuse-leap" ]; then
                    sudo zypper ref && sudo zypper up -y
                fi
            fi
            ;;
        "flatpak")
            if command -v flatpak > /dev/null 2>&1; then
                echo "${green}Detected Package Manager: $manager ${reset}"
                flatpak update -y
            fi
            ;;
        "snap")
            if command -v snap > /dev/null 2>&1; then
                echo "${green}Detected Package Manager: $manager ${reset}"
                sudo snap refresh
            fi
            ;;
        "rpm-ostree")
            if command -v rpm-ostree > /dev/null 2>&1; then
                echo "${green}Detected Package Manager: $manager ${reset}"
                sudo rpm-ostree upgrade
            fi
            ;;
    esac
done

# Checks for package manager
if command -v apt > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    # Runs script to install codecs
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_debian_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_debian_install.sh"

elif command -v dnf > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    if [ "$os" = "openmandriva" ]; then
        echo "${green}Detected Distro (ID): $os ${reset}"
        # Runs script to install codecs
        chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_openmandriva_install.sh"
        "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_openmandriva_install.sh"
    else
        # Runs script to install codecs
        chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_fedora_install.sh"
        "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_fedora_install.sh"
    fi

elif command -v xbps-install > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    # Runs script to install codecs
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_void_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_void_install.sh"

elif command -v zypper > /dev/null 2>&1; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    # Runs script to install codecs
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_opensuse_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/codecs_opensuse_install.sh"
fi

# Universal packages
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

# Distro-specific packages
arch_packages=(
"cpu-x"
"fastfetch"
"firefox"
"zram-generator"
)

aur_packages=(
"linux-lts"
"nano-syntax-highlighting"
"ttf-ms-win11-auto"
)

debian_packages=(
"cpu-x"
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
"xorg-x11-font-utils"
"zram-generator"
)

openmandriva_packages=(
"cpu-x"
"fastfetch"
"firefox"
"fonts-ttf-japanese"
"fonts-ttf-korean"
"zram-generator"
)

opensuse_packages=(
"cpu-x"
"fastfetch"
"fetchmsttfonts"
"MozillaFirefox"
"zram-generator")

void_packages=(
"CPU-X"
"fastfetch"
"firefox"
"zramen"
)

# Flatpaks
atomic_flatpaks=(
"com.transmissionbt.Transmission"
"cpu-x"
"io.mpv.Mpv"
"org.mozilla.firefox"
)

auto_flatpaks=(
"bitwarden"
"org.libreoffice.LibreOffice"
"spotify"
"vesktop")

manual_flatpaks=(
"ffmpeg-full"
"gstreamer-vaapi"
)

# Executes commands based on the operating system
case "$os" in
    "debian")
        echo "${green}Detected Distro (ID): $os ${reset}" 
        # Checks for Debian backports repository
        if ! grep -q 'backports' /etc/apt/sources.list; then
            echo "deb http://deb.debian.org/debian $(lsb_release -cs)-backports main" | sudo tee -a /etc/apt/sources.list && sudo nala update
            echo "${green}Enabled Debian backports repository ${reset}"
        fi
        
        # Installs package(s)
        sudo nala install -y firefox-esr
        ;;
    "ubuntu")
        echo "${green}Detected Distro (ID): $os ${reset}"
        # Installs package(s)
        sudo nala install -y firefox
        ;;
    *)
        case "$os_like" in
            "debian")
                echo "${green}Detected Distro (ID_LIKE): $os_like ${reset}"
                # Checks for Debian backports repository
                if ! grep -q 'backports' /etc/apt/sources.list; then
                    echo "deb http://deb.debian.org/debian $(lsb_release -cs)-backports main" | sudo tee -a /etc/apt/sources.list && sudo nala update
                    echo "${green}Enabled Debian backports repository ${reset}"
                fi
                ;;
            "ubuntu"|"ubuntu debian")
                echo "${green}Detected Distro (ID_LIKE): $os_like ${reset}"
                # Installs package(s)
                sudo nala install -y firefox
                ;;
        esac
    ;;
esac

# Checks for package manager and installs packages
if [ "$main_package_manager" = "apt" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo nala install -y "${universal_packages[@]}" "${debian_packages[@]}"

elif [ "$main_package_manager" = "dnf" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo dnf install -y "${universal_packages[@]}" "${fedora_packages[@]}"
    
    # Checks for OpenMandriva
    if [ "$os" = "openmandriva" ]; then
        echo "${green}Detected Distro (ID): $os ${reset}"
        sudo dnf install -y "${universal_packages[@]}" "${openmandriva_packages[@]}"
    else
        sudo dnf install -y "${universal_packages[@]}" "${fedora_packages[@]}"
    fi

elif [ "$main_package_manager" = "pacman" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
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
    if [ "$aur_package_manager" ]; then
        echo "${green}Detected Package Manager: $aur_package_manager ${reset}"
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

elif [ "$main_package_manager" = "xbps" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo xbps-install -Sy "${universal_packages[@]}" "${void_packages[@]}"

elif [ "$main_package_manager" = "zypper" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo zypper in -y "${universal_packages[@]}" "${opensuse_packages[@]}"

elif [ "$main_package_manager" = "rpm-ostree" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    sudo rpm-ostree install "${atomic_packages[@]}"
    flatpak install flathub -y "${atomic_flatpaks[@]}"
    
    # Creates a toolbox instance and installs packages inside of it
    toolbox create
    toolbox enter -- bash -c "dnf install -y btop dos2unix fastfetch fzf git htop inxi nano rocm-smi shellcheck smartmontools tealdeer yt-dlp && \
    echo 'Toolbox packages installed successfully'"

    # Installs Microsoft fonts
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/fedora_atomic_mscorefonts_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/fedora_atomic_mscorefonts_install.sh"
else
    echo "${red}Unsupported package manager ${reset}"
    exit 1
fi

# Checks for Fedora
if [ "$os" = "fedora" ] || [ "$os_like" = "fedora" ]; then
    echo "${green}Detected Distro (ID): $os ${reset}"
    # Installs Microsoft fonts
    sudo dnf install -y https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
fi

# Detect secondary package manager
if command -v flatpak > /dev/null 2>&1; then
    secondary_package_manager="flatpak"

elif command -v snap > /dev/null 2>&1; then
    secondary_package_manager="snap"

else
    secondary_package_manager="unknown"
fi

# Checks for package manager then installs package(s)
if [ "$main_package_manager" = "rpm-ostree" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    flatpak install flathub -y brave
else
    curl -fsS https://dl.brave.com/install.sh | sh
fi

# Checks for btrfs partitions
if mount | grep -q "type btrfs"; then
    echo "${green}Detected File System: btrfs ${reset}"
    # Checks for package manager and installs package(s)
    if [ "$main_package_manager" = "apt" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo nala install -y btrfs-compsize
        
    elif [ "$main_package_manager" = "dnf" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo dnf install -y compsize
        
    elif [ "$main_package_manager" = "pacman" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo pacman -S --needed --noconfirm compsize
        
    elif [ "$main_package_manager" = "xbps" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo xbps-install -Sy compsize
        
    elif [ "$main_package_manager" = "zypper" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo zypper in -y compsize
    fi
    
    # Checks for init system
    if [ "$init_system" = "systemd" ]; then
        echo "${green}Detected Init System: $init_system ${reset}"
        
        # Checks for package manager and installs package(s)
        if [ "$main_package_manager" = "apt" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo nala install -y btrfsmaintenance
        
        elif [ "$main_package_manager" = "dnf" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo dnf install -y btrfsmaintenance
        
        elif [ "$aur_package_manager" = "paru" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            paru -S btrfsmaintenance
            
        elif [ "$aur_package_manager" = "yay" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            yay -S btrfsmaintenance

        elif [ "$main_package_manager" = "zypper" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo zypper in -y btrfsmaintenance
        
        elif [ "$main_package_manager" = "rpm-ostree" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
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
    echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
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
    if echo "$gpu_info" | grep -iq "intel"; then
        echo "${green}Detected GPU: Intel ${reset}"
        # Installs package(s)
        flatpak install flathub org.freedesktop.Platform.VAAPI.Intel
    else
        echo "${yellow}No Intel GPU detected ${reset}"
    fi
fi

# Checks for AMD GPU
if echo "$gpu_info" | grep -iq "amd"; then
    echo "${green}Detected GPU: AMD ${reset}"
    # Checks for package manager and installs package(s)
    if command -v apt > /dev/null 2>&1; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo nala install -y rocm-smi
        
    elif command -v dnf > /dev/null 2>&1; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo dnf install -y rocm-smi
        
    elif command -v pacman > /dev/null 2>&1; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo pacman -S --needed --noconfirm rocm-smi-lib
        
    elif command -v xbps-install > /dev/null 2>&1; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        sudo xbps-install -Sy ROCm-SMI
        
    elif command -v zypper > /dev/null 2>&1; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
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
mkdir -pv "$HOME/.config/mpv"
mkdir -pv "$HOME/.config/nano"
mkdir -pv "$HOME/.var/app/io.mpv.Mpv/config/mpv"

# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/fonts.conf" "$HOME/.config/fontconfig/"
cp -v "$HOME/Documents/linux_docs/configs/packages/nanorc" "$HOME/.config/nano/"
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/99-zram.conf" /etc/sysctl.d/

# Function for user input
get_answer() {
    while true; do
        read -r -p "Install gaming packages? (y/n): " answer
        case "$answer" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Enter a 'y' or 'n'";;
        esac
    done
}

# Checks for answer
if get_answer; then
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
    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/htoprc_laptop" "$HOME/.config/htop/"
    cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv_laptop" "$HOME/.config/"
    cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv_laptop" "$HOME/.var/app/io.mpv.Mpv/config/"
    
    # Changes name(s)
    mv -v "$HOME/.config/htop/htoprc_laptop" "$HOME/.config/htop/htoprc"
    mv -v "$HOME/.config/mpv_laptop" "$HOME/.config/mpv"
    mv -v "$HOME/.var/app/io.mpv.Mpv/config/mpv_laptop" "$HOME/.var/app/io.mpv.Mpv/config/mpv"

    # Checks for init system
    if [ "$init_system" = "systemd" ]; then
        echo "${green}Detected Init System: $init_system ${reset}"
        # Copies config(s)
        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram-generator_laptop.conf" /etc/systemd/
        
        # Changes name(s)
        sudo mv -v /etc/systemd/zram-generator_laptop.conf /etc/systemd/zram-generator.conf
        
    elif [ "$init_system" = "runit" ]; then
        echo "${green}Detected Init System: $init_system ${reset}"
        # Makes zram swap device
        sudo zramen make -a lz4 -s 100
    fi

    # Checks for package manager or file, then adds kernel argument(s)
    if [ "$main_package_manager" = "rpm-ostree" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        rpm-ostree kargs --append=preempt=lazy
        
    elif [ -f /etc/default/grub ]; then
        echo "${green}Detected Bootloader: GRUB ${reset}"
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=lazy "/' /etc/default/grub
    fi
else
    echo "${green}Detected System: Desktop ${reset}"
    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/htoprc" "$HOME/.config/htop/"
    cp -rv "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.config/"
    cp -rv "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"
    
    # Checks for init system
    if [ "$init_system" = "systemd" ]; then
        echo "${green}Detected Init System: $init_system ${reset}"
        # Copies config(s)
        sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram-generator.conf" /etc/systemd/
        
    elif [ "$init_system" = "runit" ]; then
        echo "${green}Detected Init System: $init_system ${reset}"
        # Makes zram swap device
        sudo zramen make -a zstd -s 100
    fi
    
    # Checks for package manager or file, then adds kernel argument(s)
    if [ "$main_package_manager" = "rpm-ostree" ]; then
        echo "${green}Detected Package Manager: $main_package_manager ${reset}"
        rpm-ostree kargs --append=preempt=full
        
    elif [ -f /etc/default/grub ]; then
        echo "${green}Detected Bootloader: GRUB ${reset}"
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=full "/' /etc/default/grub
    fi
fi

# Detect the current desktop, trim it to the first part, and convert it to lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Prints the detected desktop
echo "Detected Desktop: $desktop"

# Executes commands based on the desktop
case "$desktop" in
    "awesome"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"openbox"|"qtile"|"sway"|"xmonad"|*wm)
        # Checks for package manager and installs package(s)
        if [ "$main_package_manager" = "apt" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo nala install -y redshift transmission-qt
        
        elif [ "$main_package_manager" = "dnf" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo dnf install -y redshift transmission-qt
        
        elif [ "$main_package_manager" = "pacman" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo pacman -S --needed --noconfirm redshift transmission-qt
        
        elif [ "$main_package_manager" = "xbps" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo xbps-install -Sy redshift transmission-qt
        
        elif [ "$main_package_manager" = "zypper" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo zypper in -y redshift transmission-qt
        fi
        
        # Checks for flatpak and installs package(s)
        if [ "$secondary_package_manager" = "flatpak" ]; then
            echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
            flatpak install flathub -y flatseal
        fi
        ;;
        
    "budgie"|"cosmic"|"deepin"|"pantheon"|"x-cinnamon")
        # Checks for package manager and installs package(s)
        if [ "$main_package_manager" = "apt" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo nala install -y transmission-gtk
        
        elif [ "$main_package_manager" = "dnf" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo dnf install -y transmission-gtk
        
        elif [ "$main_package_manager" = "pacman" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo pacman -S --needed --noconfirm transmission-gtk
        
        elif [ "$main_package_manager" = "xbps" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo xbps-install -Sy transmission-gtk
        
        elif [ "$main_package_manager" = "zypper" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo zypper in -y transmission-gtk
        fi
    
        # Checks for flatpak and installs package(s)
        if [ "$secondary_package_manager" = "flatpak" ]; then
            echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
            flatpak install flathub -y flatseal
        fi
        ;;
    "gnome")
        # Checks for package manager and installs package(s)
        if [ "$main_package_manager" = "apt" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo nala install -y chrome-gnome-shell gnome-shell-extension-manager redshift-gtk transmission-gtk
        
        elif [ "$main_package_manager" = "dnf" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo dnf install -y gnome-tweaks redshift-gtk transmission-gtk
        
        elif [ "$main_package_manager" = "pacman" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo pacman -S --needed --noconfirm gnome-tweaks redshift transmission-gtk
        
        elif [ "$main_package_manager" = "xbps" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo xbps-install -Sy gnome-tweaks redshift-gtk transmission-gtk
        
        elif [ "$main_package_manager" = "zypper" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo zypper in -y gnome-tweaks redshift-gtk transmission-gtk
        fi
            
        # Checks for flatpak and installs package(s)
        if [ "$secondary_package_manager" = "flatpak" ]; then
            echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
            flatpak install flathub -y extensionmanager flatseal
        fi

        # Enables experimental variable refresh rate support
        gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate']"
        echo "${green}Enabled option for experimental Variable Refresh Rate ${reset}"
        ;;
    "lxde"|"mate"|"unity"|"xfce")
        # Checks for package manager and installs package(s)
        if [ "$main_package_manager" = "apt" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo nala install -y redshift-gtk transmission-gtk
        
        elif [ "$main_package_manager" = "dnf" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo dnf install -y redshift-gtk transmission-gtk
        
        elif [ "$main_package_manager" = "pacman" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo pacman -S --needed --noconfirm redshift transmission-gtk
        
        elif [ "$main_package_manager" = "xbps" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo xbps-install -Sy gnome-tweaks redshift-gtk transmission-gtk
        
        elif [ "$main_package_manager" = "zypper" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo zypper in -y gnome-tweaks redshift-gtk transmission-gtk
        fi
            
        # Checks for flatpak and installs package(s)
        if [ "$secondary_package_manager" = "flatpak" ]; then
            echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
            flatpak install flathub -y flatseal
        fi
        ;;
    "lxqt")
        # Checks for package manager and installs package(s)
        if [ "$main_package_manager" = "apt" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo nala install -y kclock kweather redshift-gtk transmission-qt
        
        elif [ "$main_package_manager" = "dnf" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo dnf install -y kclock kweather redshift-gtk transmission-qt
        
        elif [ "$main_package_manager" = "pacman" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo pacman -S --needed --noconfirm kclock kweather redshift transmission-qt
        
        elif [ "$main_package_manager" = "xbps" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo xbps-install -Sy kclock kweather redshift-gtk transmission-qt
        
        elif [ "$main_package_manager" = "zypper" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo zypper in -y kclock kweather redshift-gtk transmission-qt
        fi
            
        # Checks for flatpak and installs package(s)
        if [ "$secondary_package_manager" = "flatpak" ]; then
            echo "${green}Detected Package Manager: $secondary_package_manager ${reset}"
            flatpak install flathub -y flatseal
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
        if [ "$main_package_manager" = "apt" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo nala install -y kclock kweather transmission-qt
        
        elif [ "$main_package_manager" = "dnf" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo dnf install -y kclock kweather transmission-qt
        
        elif [ "$main_package_manager" = "pacman" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo pacman -S --needed --noconfirm kclock kweather transmission-qt
        
        elif [ "$main_package_manager" = "xbps" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo xbps-install -Sy kclock kweather transmission-qt
        
        elif [ "$main_package_manager" = "zypper" ]; then
            echo "${green}Detected Package Manager: $main_package_manager ${reset}"
            sudo zypper in -y kclock kweather transmission-qt
        fi
        ;;
    *)
        echo "${red}Unsupported desktop ${reset}"
        exit 1
        ;;
esac

# Updates GRUB configuration
if command -v update-grub > /dev/null 2>&1; then
    echo "${green}Detected Bootloader: GRUB ${reset}"
    sudo update-grub
    
elif command -v grub2-mkconfig > /dev/null 2>&1; then
    echo "${green}Detected Bootloader: GRUB ${reset}"
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    
elif command -v grub-mkconfig > /dev/null 2>&1; then
    echo "${green}Detected Bootloader: GRUB ${reset}"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    
else
    echo "${yellow}GRUB not detected ${reset}"
fi

# Checks for package manager
if [ "$main_package_manager" = "pacman" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    
    # Removes all cached versions of packages except the latest and one prior version
    sudo paccache -rk1

    # Checks for init system
    if [ "$init_system" = "systemd" ]; then
        echo "${green}Detected Init System: $init_system ${reset}"
        # Enables timer to discard unused packages weekly
        sudo systemctl enable --now paccache.timer
    fi
fi

# Checks for init system
if [ "$init_system" = "systemd" ]; then
    echo "${green}Detected Init System: $init_system ${reset}"
    # Reloads systemd manager configuration
    sudo systemctl daemon-reload
fi

# Makes directory(s)
sudo mkdir -pv /etc/sysctl.d

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
if [ "$main_package_manager" = "rpm-ostree" ]; then
    echo "${green}Detected Package Manager: $main_package_manager ${reset}"
    cp -v /var/lib/flatpak/exports/share/applications/com.transmissionbt.Transmission.desktop "$HOME/.config/autostart/"
else
    cp -v /usr/share/applications/transmission*.desktop "$HOME/.config/autostart/"
fi

# Adds custom bashrc settings
cat "$HOME/Documents/linux_docs/configs/packages/bashrc" >> "$HOME/.bashrc"

# Prints a conclusive message
echo "${green}Setup is now complete${reset}"
echo "${green}Reboot to apply all changes${reset}"
