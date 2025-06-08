#!/usr/bin/env bash

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

# Makes directory(s)
mkdir -pv "$HOME/.config/btop"

# Detects the operating system and stores it in a variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "Unable to detect the operating system"
    read -p "Press enter to continue"
    exit 1
fi

# Converts the variable into lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Prints the detected operating system
echo "Detected (ID): $os"
echo "Detected (ID_LIKE): $os_like"

# Installs packages based on the detected operating system
case "$os" in
    "debian")
        # Adds contrib and non-free repositories
        sudo apt-add-repository -y contrib non-free-firmware
        
        # Adds Debian backports repository
        echo "deb http://deb.debian.org/debian bookworm-backports main" | sudo tee -a /etc/apt/sources.list && sudo nala update
        
        # Copies config(s)
        ## Change btop_old.conf to btop.conf when Debian 13 is released
        cp -v "$HOME/Documents/linux_docs/configs/packages/btop_old.conf" "$HOME/.config/btop/"
        
        # Changes name(s)
        mv -v "$HOME/.config/btop/btop_old.conf" "$HOME/.config/btop/btop.conf"
        ;;
    "kubuntu")
        # Adds repo(s)
        sudo add-apt-repository multiverse    
    
        # Installs package(s)
        sudo nala install -y kubuntu-restricted-addons kubuntu-restricted-extras
        
        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/btop.conf" "$HOME/.config/btop/"
        ;;
    "linuxmint")
        # Adds repo(s)
        sudo add-apt-repository multiverse 
        
        # Installs package(s)
        sudo nala install -y mint-meta-codecs
        
        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/btop.conf" "$HOME/.config/btop/"
        ;;
    "lubuntu")
        # Adds repo(s)
        sudo add-apt-repository multiverse
        
        # Installs package(s)
        sudo nala install -y lubuntu-restricted-addons lubuntu-restricted-extras
        
        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/btop.conf" "$HOME/.config/btop/"
        ;;
    "ubuntu")
        # Adds repo(s)
        sudo add-apt-repository multiverse
        
        # Installs package(s)
        sudo nala install -y ubuntu-restricted-addons ubuntu-restricted-extras
        
        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/btop.conf" "$HOME/.config/btop/"
        ;;
    "xubuntu")
        # Adds repo(s)
        sudo add-apt-repository multiverse
        
        # Installs package(s)
        sudo nala install -y xubuntu-restricted-addons xubuntu-restricted-extras
        
        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/btop.conf" "$HOME/.config/btop/"
        ;;
    *)
        case "$os_like" in
            "debian")
                # Adds contrib and non-free repositories
                sudo apt-add-repository -y contrib non-free-firmware
        
                # Adds Debian backports repository
                echo "deb http://deb.debian.org/debian bookworm-backports main" | sudo tee -a /etc/apt/sources.list && sudo nala update
                
                # Copies config(s)
                ## Change btop_old.conf to btop.conf when Debian 13 is released
                cp -v "$HOME/Documents/linux_docs/configs/packages/btop_old.conf" "$HOME/.config/btop/"
        
                # Changes name(s)
                mv -v "$HOME/.config/btop/btop_old.conf" "$HOME/.config/btop/btop.conf"
                ;;
            "ubuntu debian")
                # Adds repo(s)
                sudo add-apt-repository multiverse

                # Installs package(s)
                sudo nala install -y ubuntu-restricted-addons ubuntu-restricted-extras
                
                # Copies config(s)
                cp -v "$HOME/Documents/linux_docs/configs/packages/btop.conf" "$HOME/.config/btop/"
                ;;
            *)
                echo "Unsupported distribution"
                read -p "Press enter to continue"
                exit 1
                ;;
        esac
        ;;
esac

# Installs package(s)
sudo nala install -y btop cpu-x curl dos2unix flatpak fontconfig fzf git gsmartcontrol hplip htop libavcodec-extra memtest86+ mpv neofetch shellcheck smartmontools systemd-zram-generator tealdeer ttf-mscorefonts-installer yt-dlp

# Installs Brave
curl -fsS https://dl.brave.com/install.sh | sh

# Checks for optical drive
if [ -e /dev/sr0 ]; then
    echo "Optical drive detected"
    # Installs package(s)
    sudo nala install -y libdvd-pkg
else
    echo "No optical drive detected"
fi

# Checks for btrfs partitions
if mount | grep -q "type btrfs"; then
    echo "Detected File System: btrfs"
    # Installs package(s)
    sudo nala install -y btrfs-compsize btrfsmaintenance
    
    # Configures system timer(s)
    sudo systemctl disable btrfs-defrag.timer
    sudo systemctl disable btrfs-trim.timer
    sudo systemctl enable btrfs-balance.timer
    sudo systemctl enable btrfs-scrub.timer
    sudo systemctl enable btrfsmaintenance-refresh.path
else
    echo "No btrfs partitions detected"
fi

# Adds Flathub repository
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Installs package(s)
flatpak install flathub -y runtime/org.freedesktop.Platform.ffmpeg-full/x86_64/24.08 runtime/org.freedesktop.Platform.GStreamer.gstreamer-vaapi/x86_64/23.08

# Installs package(s) based on the package manager detected
if command -v snap &> /dev/null; then
    echo "Detected: snap"
    # Installs package(s)
    sudo snap install bitwarden discord libreoffice spotify
else
    echo "snap not detected"
    # Installs package(s)
    flatpak install flathub -y bitwarden discordapp app/org.libreoffice.LibreOffice/x86_64/stable spotify
fi

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for Intel GPU
if echo "$gpu_info" | grep -i "intel" &> /dev/null; then
    echo "Intel GPU detected"
    # Installs package(s)
    flatpak install flathub -y runtime/org.freedesktop.Platform.VAAPI.Intel/x86_64/24.08
else
    echo "No Intel GPU detected"
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"
mkdir -pv "$HOME/.config/btop"
mkdir -pv "$HOME/.config/fontconfig"
mkdir -pv "$HOME/.config/htop"
mkdir -pv "$HOME/.config/MangoHud"
mkdir -pv "$HOME/.config/mpv"
mkdir -pv "$HOME/.var/app/io.mpv.Mpv/config/mpv"
mkdir -pv "$HOME/Documents/mangohud/logs"

# Copies config(s)
cp -v "$HOME/Documents/linux_docs/configs/packages/fonts.conf" "$HOME/.config/fontconfig/"
cp -v "$HOME/Documents/linux_docs/configs/packages/nanorc" "$HOME/.config/"
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/99-zram.conf" /etc/sysctl.d/

# Enables nullglob so that the glob expands to nothing if no match
shopt -s nullglob

# Detects batteries and stores in a variable
batteries=(/sys/class/power_supply/BAT*)

# Checks for battery
if (( ${#batteries[@]} )); then
    echo "Detected System: Laptop"
    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/htoprc_laptop" "$HOME/.config/htop/"
    cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv_laptop" "$HOME/.config/"
    cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv_laptop" "$HOME/.var/app/io.mpv.Mpv/config/"
    sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram-generator_laptop.conf" /etc/systemd/
    
    # Changes name(s)
    mv -v "$HOME/.config/htop/htoprc_laptop" "$HOME/.config/htop/htoprc"
    mv -v "$HOME/.config/mpv_laptop" "$HOME/.config/mpv"
    mv -v "$HOME/.var/app/io.mpv.Mpv/config/mpv_laptop" "$HOME/.var/app/io.mpv.Mpv/config/mpv"
    sudo mv -v /etc/systemd/zram-generator_laptop.conf /etc/systemd/zram-generator.conf

    # Adds kernel argument(s)
    sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=lazy"/' /etc/default/grub
else
    echo "Detected System: Desktop"
    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/htoprc" "$HOME/.config/htop/"
    cp -rv "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.config/"
    cp -rv "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"
    sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram-generator.conf" /etc/systemd/
    
    # Adds kernel argument(s)
    sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=full"/' /etc/default/grub
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
        cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME/.config/autostart/"
        ;;
    "lxqt")
        # Installs package(s)
        sudo nala install -y kclock kweather redshift-gtk transmission-qt
        flatpak install flathub -y flatseal

        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME/.config/autostart/"
        ;;
    "mate")
        # Installs package(s)
        sudo nala install -y redshift-gtk transmission-gtk
        flatpak install flathub -y flatseal

        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME/.config/autostart/"
        ;;
    "pantheon")
        # Installs package(s)
        sudo nala install -y redshift-gtk transmission-gtk
        flatpak install flathub -y flatseal

        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME/.config/autostart/"
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

        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME/.config/autostart/"
        ;;
    "xfce")
        # Installs package(s)
        sudo nala install -y redshift-gtk transmission-gtk
        flatpak install flathub -y flatseal

        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME/.config/autostart/"
        ;;
    "x-cinnamon")
        # Installs package(s)
        sudo nala install -y transmission-gtk
        flatpak install flathub -y flatseal
        ;;
    *)
        echo "Unsupported desktop environment"
        read -p "Press enter to continue"
        ;;
esac

# Updates GRUB configuration
sudo update-grub

# Reloads systemd manager configuration
sudo systemctl daemon-reload

# Loads and applies kernel parameter settings from the 99-zram.conf
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Prints the contents of /etc/default/grub
cat /etc/default/grub

# Adds aliases to bash profile
cat "$HOME/Documents/linux_docs/configs/aliases/apt_aliases.txt" >> "$HOME/.bashrc"

# Prints a conclusive message
echo "Setup is now complete"
echo "Reboot to apply all changes"
read -p "Press enter to exit"
