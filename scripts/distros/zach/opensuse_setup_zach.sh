#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Uninstalls package(s)
sudo zypper rm --clean-deps -y vlc

# Installs package(s)
sudo zypper ref && sudo zypper dup && sudo zypper in -y btop cpu-x curl fastfetch fetchmsttfonts fzf google-noto-sans-jp-fonts google-noto-sans-kr-fonts grub2-snapper-plugin gsmartcontrol hplip htop memtest86+ setroubleshoot smartmontools tealdeer yt-dlp zram-generator

# Check for Btrfs partitions
if mount | grep -q "type btrfs "; then
    echo "Btrfs partition detected"
    # Installs package(s)
    sudo zypper in -y compsize btrfsmaintenance
    
    # Configures system timer(s)
    sudo systemctl disable btrfs-defrag.timer
    sudo systemctl disable btrfs-trim.timer
    sudo systemctl enable btrfs-balance.timer
    sudo systemctl enable btrfs-scrub.timer
    sudo systemctl enable btrfsmaintenance-refresh.path
else
    echo "No Btrfs partitions detected"
fi

# Adds current user to wheel group if they are not already
sudo usermod -aG wheel $USER

# Adds Flathub repository
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Installs package(s)
flatpak install flathub -y runtime/org.freedesktop.Platform.ffmpeg-full/x86_64/24.08 runtime/org.freedesktop.Platform.GStreamer.gstreamer-vaapi/x86_64/23.08 app/org.libreoffice.LibreOffice/x86_64/stable

# Gets GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for Intel GPU
if echo "$gpu_info" | grep -i "intel" &> /dev/null; then
    echo "Intel GPU detected"
    # Installs package(s)
    flatpak install flathub -y runtime/org.freedesktop.Platform.VAAPI.Intel/x86_64/24.08
else
    echo "No Intel GPU detected"
fi

# Function to get a valid yes or no response
get_confirmation() {
    while true; do
        read -p "Install multimedia codecs from Packman? (y/n): " choice
        case "$choice" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Enter a 'y' or 'n'";;
        esac
    done
}

# Call the function and act based on the user's response
if get_confirmation; then
    # Installs package(s)
    sudo zypper in -y opi
    
    # Installs codecs
    opi codecs
    
    # Installs Brave
    curl -fsS https://dl.brave.com/install.sh | sh
    
    # Installs package(s)
    sudo dnf install -y discord mpv
else
    # Uninstalls package(s)
    sudo zypper rm --clean-deps -y MozillaFirefox
    
    # Installs package(s)
    flatpak install flathub -y brave discordapp app/org.mozilla.firefox/x86_64/stable app/io.mpv.Mpv/x86_64/stable
fi

# Makes directory(s)
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
    mkdir -pv $HOME/.config/MangoHud
    mkdir -pv $HOME/Documents/MangoHud/logs 
    
    # Copies config(s)
    cp -v $HOME/Documents/linux_docs/configs/packages/nanorc $HOME/.config/
    mv -v $HOME/Documents/linux_docs/configs/packages/nanorc $HOME/.config/.nanorc
    
    # Copies config(s)
    cp -v $HOME/Documents/linux_docs/configs/packages/htoprc_laptop $HOME/.config/htop/
    mv -v $HOME/.config/htop/htoprc_laptop $HOME/.config/htop/htoprc
    
    # Copies config(s)
    cp -v $HOME/Documents/linux_docs/configs/packages/btop.conf $HOME/.config/btop/
    
    # Copies config(s)
    cp -vr $HOME/Documents/linux_docs/configs/packages/mpv_laptop $HOME/.config/
    mv -v $HOME/.config/mpv_laptop $HOME/.config/mpv
    cp -vr $HOME/Documents/linux_docs/configs/packages/mpv_laptop $HOME/.var/app/io.mpv.Mpv/config/
    mv -v $HOME/.var/app/io.mpv.Mpv/config/mpv_laptop $HOME/.var/app/io.mpv.Mpv/config/mpv
    
    # Copies config(s)
    cp -v $HOME/Documents/linux_docs/configs/packages/MangoHud_laptop.conf $HOME/.config/MangoHud/
    mv -v $HOME/.config/MangoHud/MangoHud_laptop.conf $HOME/.config/MangoHud/MangoHud.conf 
    
    # Copies config(s)
    sudo cp -v $HOME/Documents/linux_docs/configs/packages/zram-generator_laptop.conf /etc/systemd/
    sudo mv -v /etc/systemd/zram-generator_laptop.conf /etc/systemd/zram-generator.conf
    sudo cp -v $HOME/Documents/linux_docs/configs/packages/99-zram.conf /etc/sysctl.d/

    # Adds kernel argument(s)
    sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=lazy"/' /etc/default/grub
else
    echo "No battery detected"
    # Installs package(s)
    sudo zypper in -y mangohud mangohud-32bit selinux-policy-targeted-gaming steam
    flatpak install flathub -y furmark lact runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08 prismlauncher com.github.Matoking.protontricks/x86_64/stable

    # Grants flatpaks read-only access to MangoHud's config file
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark 
    flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher
    
    # Makes directory(s)
    mkdir -pv $HOME/.config/htop
    mkdir -pv $HOME/.config/btop
    mkdir -pv $HOME/.config/mpv
    mkdir -pv $HOME/.var/app/io.mpv.Mpv/config/mpv
    mkdir -pv $HOME/.config/MangoHud
    mkdir -pv $HOME/Documents/MangoHud/logs
    
    # Copies config(s)
    cp -v $HOME/Documents/linux_docs/configs/packages/nanorc $HOME/.config/
    mv -v $HOME/Documents/linux_docs/configs/packages/nanorc $HOME/.config/.nanorc
    
    # Copies config(s)
    cp -v $HOME/Documents/linux_docs/configs/packages/htoprc $HOME/.config/htop/
    
    # Copies config(s)
    cp -v $HOME/Documents/linux_docs/configs/packages/btop.conf $HOME/.config/btop/
    
    # Copies config(s)
    cp -vr $HOME/Documents/linux_docs/configs/packages/mpv $HOME/.config/mpv/config/
    cp -vr $HOME/Documents/linux_docs/configs/packages/mpv $HOME/.var/app/io.mpv.Mpv/config/
    
    # Copies config(s)
    cp -v $HOME/Documents/linux_docs/configs/packages/MangoHud_zach.conf $HOME/.config/MangoHud/
    mv -v $HOME/.config/MangoHud/MangoHud_zach.conf $HOME/.config/MangoHud/MangoHud.conf
    
    # Copies config(s)
    sudo cp -v $HOME/Documents/linux_docs/configs/packages/zram-generator.conf /etc/systemd/
    sudo cp -v $HOME/Documents/linux_docs/configs/packages/99-zram.conf /etc/sysctl.d/
    
    # Enables LACT
    sudo systemctl enable --now lactd

    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
        echo "AMD GPU detected"
        # Adds kernel argument(s)
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
    else
        echo "No AMD GPU detected"
    fi

    # Adds kernel argument(s)
    sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=full"/' /etc/default/grub

    # Runs script to install latest Proton GE
    chmod +x $HOME/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh
    $HOME/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh
fi

# Detects the desktop environment and stores in a variable, then converts it into lowercase
desktop_env=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Prints the detected desktop environment
echo "Detected: $desktop_env"

# Conditional execution based on the desktop environment
case "$desktop_env" in
    "gnome")
        # Installs package(s)
        sudo zypper in -y gnome-tweaks transmission-gtk
        flatpak install flathub -y extensionmanager flatseal
        
        # Uninstalls package(s)
        sudo zypper rm --clean-deps -y gnome-tour
        
        # Enables experimental variable refresh rate support
        gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate']"
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
        sudo zypper in -y kclock kweather transmission-qt
        ;;
    "lxqt")
        # Installs package(s)
        sudo zypper in -y kclock kweather redshift-gtk transmission-qt
        flatpak install flathub -y flatseal
        
        # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/redshift.conf $HOME/.config/
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop $HOME/.config/autostart/
        ;;
    "lxde")
        # Installs package(s)
        sudo zypper in -y redshift-gtk transmission-gtk
        flatpak install flathub -y flatseal
        
        # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/redshift.conf $HOME/.config/
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop $HOME/.config/autostart/
        ;;
    "mate")
        # Installs package(s)
        sudo zypper in -y redshift-gtk transmission-gtk
        flatpak install flathub -y flatseal
        
        # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/redshift.conf $HOME/.config/
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop $HOME/.config/autostart/
        ;;
    "xfce")
        # Installs package(s)
        sudo zypper in -y redshift-gtk transmission-gtk
        flatpak install flathub -y flatseal
        
        # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/redshift.conf $HOME/.config/
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop $HOME/.config/autostart/
        ;;
    "x-cinnamon")
        # Installs package(s)
        sudo zypper in -y transmission-gtk
        flatpak install flathub -y flatseal
        ;;
    "budgie")
        # Installs package(s)
        sudo zypper in -y transmission-gtk
        flatpak install flathub -y flatseal
        ;;
    *)
        echo "Nothing to do for $desktop_env"
        ;;
esac

# Adds firewall exceptions
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
cat $HOME/Documents/linux_docs/configs/aliases/aliases_opensuse.txt >> $HOME/.bashrc

# Prints a conclusive message to end the script
echo "Setup is now complete. Reboot to apply all changes."
