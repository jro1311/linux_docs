#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Removes package(s)
sudo xbps-remove -Ry firefox

# Upgrades system
sudo xbps-install -Suy xbps && sudo xbps-install -uy

# Installs package(s)
sudo xbps-install -y btop cabextract CPU-X curl dos2unix faac fastfetch flac flatpak fontconfig fzf git hplip htop inxi memtest86+ mpv nano pciutils smartmontools tealdeer x264 x265 yt-dlp zramen

# Installs Brave
curl -fsS https://dl.brave.com/install.sh | sh

# Checks for optical drive
if [ -e /dev/sr0 ]; then
    echo "Optical drive detected"
    # Installs package(s)
    sudo xbps-install -y libdvdcss libdvdnav libdvdread
else
    echo "No optical drive detected"
fi

# Checks for wheel group
if getent group wheel > /dev/null 2>&1; then
    # Adds current user to wheel group
    sudo usermod -aG wheel "$USER"
else
    echo "wheel group does not exist"
fi

# Adds Flathub repository
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Installs package(s)
flatpak install flathub -y librewolf org.libreoffice.LibreOffice

# Installs package(s)
flatpak install flathub ffmpeg-full gstreamer-vaapi

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for Intel GPU
if echo "$gpu_info" | grep -i "intel" &> /dev/null; then
    echo "Detected GPU: Intel"
    # Installs package(s)
    flatpak install flathub org.freedesktop.Platform.VAAPI.Intel
else
    echo "No Intel GPU detected"
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
cp -v "$HOME/Documents/linux_docs/configs/packages/btop.conf" "$HOME/.config/btop/"
cp -v "$HOME/Documents/linux_docs/configs/packages/fonts.conf" "$HOME/.config/fontconfig/"
cp -v "$HOME/Documents/linux_docs/configs/packages/nanorc" "$HOME/.config/nano/"
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
    
    # Changes name(s)
    mv -v "$HOME/.config/htop/htoprc_laptop" "$HOME/.config/htop/htoprc"
    mv -v "$HOME/.config/mpv_laptop" "$HOME/.config/mpv"
    mv -v "$HOME/.var/app/io.mpv.Mpv/config/mpv_laptop" "$HOME/.var/app/io.mpv.Mpv/config/mpv"
    
    # Makes zram swap device
    sudo zramen make -a lz4 -s 100

    # Adds kernel argument(s)
    sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=lazy"/' /etc/default/grub
else
    echo "Detected System: Desktop"
    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/htoprc" "$HOME/.config/htop/"
    cp -rv "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.config/"
    cp -rv "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"

    # Makes zram swap device
    sudo zramen make -a zstd -s 100

    # Adds kernel argument(s)
    sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=full"/' /etc/default/grub
fi

# Detects the desktop environment or window manager, shortens it, then converts it into lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Prints the detected desktop
echo "Detected Desktop: $desktop"

# Conditional execution based on the desktop
case "$desktop" in
    "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
        # Installs package(s)
        sudo xbps-install -y redshift-gtk transmission-qt
        flatpak install flathub -y flatseal

        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME/.config/autostart/"
        ;;
    "budgie"|"cosmic"|"deepin"|"pantheon"|"x-cinnamon")
        # Installs package(s)
        sudo xbps-install -y transmission-gtk
        flatpak install flathub -y flatseal
        ;;
    "gnome")
        # Installs package(s)
        sudo xbps-install -y gnome-tweaks transmission-gtk
        flatpak install flathub -y extensionmanager flatseal
        
        # Removes package(s)
        sudo xbps-remove -R -y gnome-tour

        # Enables experimental variable refresh rate support
        gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate']"
        ;;
    "lxde"|"mate"|"unity"|"xfce")
        # Installs package(s)
        sudo xbps-install -y redshift-gtk transmission-gtk
        flatpak install flathub -y flatseal

        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME/.config/autostart/"
        ;;
    "lxqt")
        # Installs package(s)
        sudo xbps-install -y kclock kweather redshift-gtk transmission-qt
        flatpak install flathub -y flatseal

        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME/.config/autostart/"
        ;;
    "plasma")
        # Disables Baloo (KDE file indexer)
        balooctl6 disable

        # Installs package(s)
        sudo xbps-install -y kclock kweather transmission-qt
        ;;
    *)
        echo "Unsupported desktop"
        read -p "Press enter to continue"
        ;;
esac

# Updates GRUB configuration
sudo update-grub

# Makes directory(s)
sudo mkdir -pv /etc/sysctl.d

# Loads and applies kernel parameter settings
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Prints the contents of /etc/default/grub
cat /etc/default/grub

# Adds custom bashrc settings
cat "$HOME/Documents/linux_docs/configs/packages/bashrc" >> "$HOME/.bashrc"

# Prints a conclusive message
echo "Setup is now complete"
echo "Reboot to apply all changes"
read -p "Press enter to exit"
