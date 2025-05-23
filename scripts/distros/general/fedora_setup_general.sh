#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Uninstalls package(s)
sudo dnf remove -y libreoffice*

# Installs package(s)
sudo dnf upgrade -y && sudo dnf install -y btop cabextract cpu-x curl fastfetch flatpak fontconfig fzf google-noto-sans-jp-fonts google-noto-sans-kr-fonts gsmartcontrol hplip htop memtest86+ pciutils smartmontools tealdeer xorg-x11-font-utils yt-dlp zram-generator

# Check for Btrfs partitions
if mount | grep -q "type btrfs "; then
    echo "Btrfs partition detected"
    # Installs package(s)
    sudo dnf install -y compsize btrfsmaintenance
    
    # Configures system timer(s)
    sudo systemctl disable btrfs-defrag.timer
    sudo systemctl disable btrfs-trim.timer
    sudo systemctl enable btrfs-balance.timer
    sudo systemctl enable btrfs-scrub.timer
    sudo systemctl enable btrfsmaintenance-refresh.path
else
    echo "No Btrfs partitions detected"
fi

# Installs Microsoft fonts
sudo dnf install -y https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# Adds current user to wheel group if they are not already
sudo usermod -aG wheel $USER

# Disables Fedora Flatpak repositority
flatpak remote-modify --disable fedora

# Adds Flathub repository
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Installs package(s)
flatpak install flathub -y runtime/org.freedesktop.Platform.ffmpeg-full/x86_64/24.08 runtime/org.freedesktop.Platform.GStreamer.gstreamer-vaapi/x86_64/23.08 app/org.libreoffice.LibreOffice/x86_64/stable

# Function to get a valid yes or no response
get_confirmation() {
    while true; do
        read -p "Install multimedia codecs from RPM Fusion? (y/n): " choice
        case "$choice" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Enter a 'y' or 'n'";;
        esac
    done
}

# Call the function and act based on the user's response
if get_confirmation; then
    # Runs script to install RPM Fusion and multimedia codecs
    chmod +x $HOME/Documents/linux_docs/scripts/packages/terminal/codecs_rpm_fusion_install.sh
    $HOME/Documents/linux_docs/scripts/packages/terminal/codecs_rpm_fusion_install.sh
    
    # Installs Brave
    curl -fsS https://dl.brave.com/install.sh | sh
    
    # Installs package(s)
    sudo dnf install -y discord mpv
else
    # Uninstalls package(s)
    sudo dnf remove -y firefox
    
    # Installs package(s)
    flatpak install flathub -y brave app/org.mozilla.firefox/x86_64/stable app/io.mpv.Mpv/x86_64/stable
fi

# Creates an autostart directory if it doesn't already exist
mkdir -pv $HOME/.config/autostart

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
    # Makes directory(s)
    mkdir -pv $HOME/.config/htop
    mkdir -pv $HOME/.config/btop
    mkdir -pv $HOME/.config/mpv
    mkdir -pv $HOME/.var/app/io.mpv.Mpv/config/mpv
    
    # Copies config(s)
    cp -v $HOME/Documents/linux_docs/configs/packages/nanorc $HOME/.config/
    cp -v $HOME/Documents/linux_docs/configs/packages/htoprc_laptop $HOME/.config/htop/
    cp -v $HOME/Documents/linux_docs/configs/packages/btop.conf $HOME/.config/btop/
    cp -vr $HOME/Documents/linux_docs/configs/packages/mpv_laptop $HOME/.config/
    cp -vr $HOME/Documents/linux_docs/configs/packages/mpv_laptop $HOME/.var/app/io.mpv.Mpv/config/
    sudo cp -v $HOME/Documents/linux_docs/configs/packages/zram-generator_laptop.conf /etc/systemd/
    sudo cp -v $HOME/Documents/linux_docs/configs/packages/99-zram.conf /etc/sysctl.d/
    
    # Changes name(s)
    mv -v $HOME/.config/nanorc $HOME/.config/.nanorc
    mv -v $HOME/.config/htop/htoprc_laptop $HOME/.config/htop/htoprc
    mv -v $HOME/.config/mpv_laptop $HOME/.config/mpv
    mv -v $HOME/.var/app/io.mpv.Mpv/config/mpv_laptop $HOME/.var/app/io.mpv.Mpv/config/mpv
    sudo mv -v /etc/systemd/zram-generator_laptop.conf /etc/systemd/zram-generator.conf
    
    # Adds kernel argument(s)
    sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=lazy"/' /etc/default/grub
else
    echo "No battery detected"
    # Makes directory(s)
    mkdir -pv $HOME/.config/htop
    mkdir -pv $HOME/.config/btop
    mkdir -pv $HOME/.config/mpv
    mkdir -pv $HOME/.var/app/io.mpv.Mpv/config/mpv

    # Copies config(s)
    cp -v $HOME/Documents/linux_docs/configs/packages/nanorc $HOME/.config/
    cp -v $HOME/Documents/linux_docs/configs/packages/htoprc $HOME/.config/htop/
    cp -v $HOME/Documents/linux_docs/configs/packages/btop.conf $HOME/.config/btop/
    cp -vr $HOME/Documents/linux_docs/configs/packages/mpv $HOME/.config/mpv/config/
    cp -vr $HOME/Documents/linux_docs/configs/packages/mpv $HOME/.var/app/io.mpv.Mpv/config/
    sudo cp -v $HOME/Documents/linux_docs/configs/packages/zram-generator.conf /etc/systemd/
    sudo cp -v $HOME/Documents/linux_docs/configs/packages/99-zram.conf /etc/sysctl.d/
    
    # Changes name(s)
    mv -v $HOME/.config/nanorc $HOME/.config/.nanorc

    # Adds kernel argument(s)
    sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=full"/' /etc/default/grub
fi

# Detects the desktop environment and stores in a variable, then converts it into lowercase
desktop_env=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Prints the detected desktop environment
echo "Detected: $desktop_env"

# Conditional execution based on the desktop environment
case "$desktop_env" in
    "gnome")
        # Installs package(s)
        sudo dnf install -y gnome-tweaks transmission-gtk
        flatpak install flathub -y extensionmanager flatseal

        # Enables experimental variable refresh rate support
        gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate']"
        ;;
    "plasma")
        # Disables Baloo (KDE file indexer)
        balooctl6 disable
        
        # Installs package(s)
        sudo dnf install -y kclock kweather transmission-qt
        ;;
    "lxqt")
        # Installs package(s)
        sudo dnf install -y kclock kweather redshift-gtk transmission-qt
        flatpak install flathub -y flatseal

        # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/redshift.conf $HOME/.config/

        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop $HOME/.config/autostart/
        ;;
    "lxde")
        # Installs package(s)
        sudo dnf install -y redshift-gtk transmission-gtk
        flatpak install flathub -y flatseal

        # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/redshift.conf $HOME/.config/

        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop $HOME/.config/autostart/
        ;;
    "mate")
        # Installs package(s)
        sudo dnf install -y redshift-gtk transmission-gtk
        flatpak install flathub -y flatseal

        # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/redshift.conf $HOME/.config/

        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop $HOME/.config/autostart/
        ;;
    "xfce")
        # Installs package(s)
        sudo dnf install -y redshift-gtk transmission-gtk
        flatpak install flathub -y flatseal

        # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/redshift.conf $HOME/.config/

        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop $HOME/.config/autostart/
        ;;
    "x-cinnamon")
        # Installs package(s)
        sudo dnf install -y transmission-gtk
        flatpak install flathub -y flatseal
        ;;
    "budgie")
        # Installs package(s)
        sudo dnf install -y transmission-gtk
        flatpak install flathub -y flatseal
        ;;
    *)
        echo "Nothing to do for $desktop_env"
        ;;
esac

# Updates grub configuration
sudo grub2-mkconfig

# Reloads systemd manager configuration
sudo systemctl daemon-reload

# Loads and applies kernel parameter settings from the 99-zram.conf
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Prints the contents of /etc/default/grub
cat /etc/default/grub

# Lists files in the autostart directory
ls $HOME/.config/autostart/

# Adds aliases to bash profile
cat $HOME/Documents/linux_docs/configs/aliases/aliases_fedora.txt >> $HOME/.bashrc

# Prints a conclusive message to end the script
echo "Setup is now complete. Reboot to apply all changes."
