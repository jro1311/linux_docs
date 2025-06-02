#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Refreshes package repositories and installs package(s)
sudo apt update && sudo apt install -y nala

# Uninstalls package(s)
sudo nala remove -y libreoffice*

# Updates system
sudo nala upgrade -y

# Installs package(s)
sudo nala install -y software-properties-common

# Detects the operating system and stores it in a variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS="${ID:-unknown}"
    
    # Fallback to $OS if ID_LIKE is missing
    OS_LIKE="${ID_LIKE:-$OS}"
else
    echo "Unable to detect the operating system"
    exit 1
fi

# Converts the variable into lowercase
OS=$(echo "${OS:-unknown}" | tr '[:upper:]' '[:lower:]')
OS_LIKE=$(echo "$OS_LIKE" | tr '[:upper:]' '[:lower:]')

# Prints the detected operating system
echo "Detected: $OS"

# Installs packages based on the detected operating system
case "$OS" in
    "debian")
        # Adds contrib and non-free repositories
        sudo apt-add-repository -y contrib non-free-firmware
        
        # Adds Debian backports repository
        echo "deb http://deb.debian.org/debian bookworm-backports main" | sudo tee -a /etc/apt/sources.list && sudo nala update
        ;;
    "kubuntu")
        # Adds repo(s)
        sudo add-apt-repository multiverse    
    
        # Installs package(s)
        sudo nala install -y kubuntu-restricted-addons kubuntu-restricted-extras
        ;;
    "linuxmint")
        # Installs package(s)
        sudo nala install -y mint-meta-codecs
        ;;
    "lubuntu")
        # Adds repo(s)
        sudo add-apt-repository multiverse
        
        # Installs package(s)
        sudo nala install -y lubuntu-restricted-addons lubuntu-restricted-extras
        ;;
    "ubuntu")
        # Adds repo(s)
        sudo add-apt-repository multiverse
        
        # Installs package(s)
        sudo nala install -y ubuntu-restricted-addons ubuntu-restricted-extras
        ;;
    "xubuntu")
        # Adds repo(s)
        sudo add-apt-repository multiverse
        
        # Installs package(s)
        sudo nala install -y xubuntu-restricted-addons xubuntu-restricted-extras
        ;;
    *)
        case "$OS_LIKE" in
            "debian")
                # Adds contrib and non-free repositories
                sudo apt-add-repository -y contrib non-free-firmware
        
                # Adds Debian backports repository
                echo "deb http://deb.debian.org/debian bookworm-backports main" | sudo tee -a /etc/apt/sources.list && sudo nala update
                ;;
            "ubuntu debian")
                # Adds repo(s)
                sudo add-apt-repository multiverse

                # Installs package(s)
                sudo nala install -y ubuntu-restricted-addons ubuntu-restricted-extras
                ;;
            *)
                echo "Unsupported distribution: $OS"
                exit 1
                ;;
        esac
        ;;
esac

# Installs package(s)
sudo nala install -y btop cpu-x curl flatpak fontconfig fzf gsmartcontrol hplip htop libavcodec-extra memtest86+ mpv neofetch smartmontools systemd-zram-generator tealdeer ttf-mscorefonts-installer yt-dlp

# Installs Brave
curl -fsS https://dl.brave.com/install.sh | sh

# Checks for btrfs partitions
if mount | grep -q "type btrfs "; then
    echo "btrfs detected"
    # Installs package(s)
    sudo nala install -y btrfs-compsize btrfsmaintenance
    
    # Configures system timer(s)
    sudo systemctl disable btrfs-defrag.timer
    sudo systemctl disable btrfs-trim.timer
    sudo systemctl enable btrfs-balance.timer
    sudo systemctl enable btrfs-scrub.timer
    sudo systemctl enable btrfsmaintenance-refresh.path
else
    echo "btrfs not detected"
fi

# Adds Flathub repository
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Installs package(s)
flatpak install flathub -y runtime/org.freedesktop.Platform.ffmpeg-full/x86_64/24.08 runtime/org.freedesktop.Platform.GStreamer.gstreamer-vaapi/x86_64/23.08

# Installs package(s) based on the package manager detected
if command -v snap &> /dev/null; then
    echo "Snap detected"
    # Installs package(s)
    sudo snap install bitwarden discord libreoffice spotify
else
    echo "Snap not detected"
    # Installs package(s)
    flatpak install flathub -y bitwarden discordapp app/org.libreoffice.LibreOffice/x86_64/stable spotify
fi

# Gets GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for Intel GPU
if echo "$gpu_info" | grep -i "intel" &> /dev/null; then
    echo "Intel GPU detected"
    # Installs package(s)
    flatpak install flathub -y runtime/org.freedesktop.Platform.VAAPI.Intel/x86_64/24.08
else
    echo "No Intel GPU detected."
fi

# Makes directory(s)
mkdir -pv "$HOME"/.config/autostart
mkdir -pv "$HOME"/.config/htop
mkdir -pv "$HOME"/.config/btop
mkdir -pv "$HOME"/.config/mpv
mkdir -pv "$HOME"/.var/app/io.mpv.Mpv/config/mpv
mkdir -pv "$HOME"/.config/MangoHud
mkdir -pv "$HOME"/Documents/mangohud/logs
mkdir -pv ~/.config/fontconfig

# Copies config(s)
## Change btop_old.conf to btop.conf when Debian 13 is released
cp -v "$HOME"/Documents/linux_docs/configs/packages/nanorc "$HOME"/.config/
cp -v "$HOME"/Documents/linux_docs/configs/packages/btop_old.conf "$HOME"/.config/btop/
cp -v "$HOME"/Documents/linux_docs/configs/packages/fonts.conf "$HOME"/.config/fontconfig/
sudo cp -v "$HOME"/Documents/linux_docs/configs/packages/99-zram.conf /etc/sysctl.d/

# Changes name(s)
mv -v "$HOME"/.config/btop/btop_old.conf "$HOME"/.config/btop/btop.conf

# Function to check for battery presence
check_battery() {
    if [ -d /sys/class/power_supply/BAT0 ] || [ -d /sys/class/power_supply/BAT1 ]; then
        return 0  # Battery detected
    else
        return 1  # No battery detected
    fi
}

# Check for battery
if check_battery; then
    echo "Battery detected"
    # Copies config(s)
    cp -v "$HOME"/Documents/linux_docs/configs/packages/htoprc_laptop "$HOME"/.config/htop/
    cp -vr "$HOME"/Documents/linux_docs/configs/packages/mpv_laptop "$HOME"/.config/
    cp -vr "$HOME"/Documents/linux_docs/configs/packages/mpv_laptop "$HOME"/.var/app/io.mpv.Mpv/config/
    cp -v "$HOME"/Documents/linux_docs/configs/packages/MangoHud_laptop.conf "$HOME"/.config/MangoHud/
    sudo cp -v "$HOME"/Documents/linux_docs/configs/packages/zram-generator_laptop.conf /etc/systemd/
    
    # Changes name(s)
    mv -v "$HOME"/.config/htop/htoprc_laptop "$HOME"/.config/htop/htoprc
    mv -v "$HOME"/.config/mpv_laptop "$HOME"/.config/mpv
    mv -v "$HOME"/.var/app/io.mpv.Mpv/config/mpv_laptop "$HOME"/.var/app/io.mpv.Mpv/config/mpv
    mv -v "$HOME"/.config/MangoHud/MangoHud_laptop.conf "$HOME"/.config/MangoHud/MangoHud.conf 
    sudo mv -v /etc/systemd/zram-generator_laptop.conf /etc/systemd/zram-generator.conf

    # Adds kernel argument(s)
    sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=lazy"/' /etc/default/grub
else
    echo "No battery detected"
    # Installs package(s)
    sudo nala install -y mangohud steam-installer
    flatpak install flathub -y furmark heroicgameslauncher lact runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08 prismlauncher com.github.Matoking.protontricks/x86_64/stable

    # Grants flatpaks read-only access to MangoHud's config file
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark 
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
    flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher
    
    # Copies config(s)
    cp -v "$HOME"/Documents/linux_docs/configs/packages/htoprc "$HOME"/.config/htop/
    cp -vr "$HOME"/Documents/linux_docs/configs/packages/mpv "$HOME"/.config/
    cp -vr "$HOME"/Documents/linux_docs/configs/packages/mpv "$HOME"/.var/app/io.mpv.Mpv/config/
    cp -v "$HOME"/Documents/linux_docs/configs/packages/MangoHud.conf "$HOME"/.config/MangoHud/
    sudo cp -v "$HOME"/Documents/linux_docs/configs/packages/zram-generator.conf /etc/systemd/
    
    # Enables LACT
    sudo systemctl enable --now lactd

    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
        echo "AMD GPU detected"
        # Installs package(s)
        sudo nala install -y rocm-smi
        
        # Adds kernel argument(s)
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
    else
        echo "No AMD GPU detected"
    fi

    # Adds kernel argument(s)
    sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=full"/' /etc/default/grub

    # Runs script to install latest Proton GE
    chmod +x "$HOME"/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh
    "$HOME"/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh
fi

# Detects the desktop environment and stores in a variable, then converts it into lowercase
desktop_env=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Prints the detected desktop environment
echo "Detected: $desktop_env"

# Conditional execution based on the desktop environment
case "$desktop_env" in
    "budgie")
        # Installs package(s)
        sudo nala install -y transmission-gtk
        flatpak install flathub -y flatseal
        ;;
    "gnome")
        # Installs package(s)
        sudo nala install -y chrome-gnome-shell gnome-shell-extension-manager gnome-tweaks transmission-gtk
        flatpak install flathub -y extensionmanager flatseal

        # Enables experimental variable refresh rate support
        gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate']"
        ;;
    "deepin")
        # Installs package(s)
        sudo nala install -y kclock kweather transmission-qt
        flatpak install flathub -y flatseal
        ;;
    "lxde")
        # Installs package(s)
        sudo nala install -y redshift-gtk transmission-gtk
        flatpak install flathub -y flatseal

        # Copies config(s) 
        cp -v "$HOME"/Documents/linux_docs/configs/packages/redshift.conf "$HOME"/.config/

        # Adds pacakge(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME"/.config/autostart/
        ;;
    "lxqt")
        # Installs package(s)
        sudo nala install -y kclock kweather redshift-gtk transmission-qt
        flatpak install flathub -y flatseal

        # Copies config(s) 
        cp -v "$HOME"/Documents/linux_docs/configs/packages/redshift.conf "$HOME"/.config/

        # Adds pacakge(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME"/.config/autostart/
        ;;
    "mate")
        # Installs package(s)
        sudo nala install -y redshift-gtk transmission-gtk
        flatpak install flathub -y flatseal

        # Copies config(s) 
        cp -v "$HOME"/Documents/linux_docs/configs/packages/redshift.conf "$HOME"/.config/

        # Adds pacakge(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME"/.config/autostart/
        ;;
    "pantheon")
        # Installs package(s)
        sudo nala install -y redshift-gtk transmission-gtk
        flatpak install flathub -y flatseal

        # Copies Redshift config(s)
        cp -v "$HOME"/Documents/linux_docs/configs/packages/redshift.conf "$HOME"/.config/

        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME"/.config/autostart/
        ;;
    "plasma")
        # Disables Baloo (KDE file indexer)
        if command -v balooctl6 >/dev/null 2>&1; then
            balooctl6 disable
        elif command -v balooctl >/dev/null 2>&1; then
            balooctl disable
        fi
        echo "Baloo disabled"
        
        # Installs package(s)
        sudo nala install -y kclock kweather transmission-qt
        ;;
    "unity")
        # Installs package(s)
        sudo nala install -y redshift-gtk transmission-gtk
        flatpak install flathub -y flatseal

        # Copies Redshift config(s)
        cp -v "$HOME"/Documents/linux_docs/configs/packages/redshift.conf "$HOME"/.config/

        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME"/.config/autostart/
        ;;
    "xfce")
        # Installs package(s)
        sudo nala install -y redshift-gtk transmission-gtk
        flatpak install flathub -y flatseal

        # Copies config(s) 
        cp -v "$HOME"/Documents/linux_docs/configs/packages/redshift.conf "$HOME"/.config/

        # Adds pacakge(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME"/.config/autostart/
        ;;
    "x-cinnamon")
        # Installs package(s)
        sudo nala install -y transmission-gtk
        flatpak install flathub -y flatseal
        ;;
    *)
        echo "Unsupported desktop environment: $desktop_env"
        ;;
esac

# Adds package(s) to autostart
cp -v /usr/share/applications/transmission*.desktop "$HOME"/.config/autostart/

# Updates grub configuration
sudo update-grub

# Reloads systemd manager configuration
sudo systemctl daemon-reload

# Loads and applies kernel parameter settings from the 99-zram.conf
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Prints the contents of /etc/default/grub
cat /etc/default/grub

# Lists files in the autostart directory
ls "$HOME"/.config/autostart/

# Adds aliases to bash profile
cat "$HOME"/Documents/linux_docs/configs/aliases/aliases_debian.txt >> "$HOME"/.bashrc

# Prints a conclusive message to end the script
echo "Setup is now complete. Reboot to apply all changes."
