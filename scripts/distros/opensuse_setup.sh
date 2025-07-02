#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for package manager
if ! command -v zypper > /dev/null 2>&1; then
    echo "Unsupported package manager"
    read -p "Press enter to exit"
    exit 1
fi

# Detects the operating system and stores it in a variable
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os="${ID:-unknown}"
    os_like="${ID_LIKE:-$os}"
else
    echo "Unable to detect the operating system"
    read -p "Press enter to exit"
    exit 1
fi

# Converts the variable into lowercase
os=$(echo "${os:-unknown}" | tr '[:upper:]' '[:lower:]')
os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

# Prints the detected operating system
echo "Detected (ID): $os"
echo "Detected (ID_LIKE): $os_like"

# Removes package(s)
sudo zypper rm --clean-deps -y vlc

# Upgrades system
if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
    sudo zypper ref && sudo zypper dup -y
elif [ "$os" = "opensuse-leap" ]; then
    sudo zypper ref && sudo zypper up -y
else
    echo "Unsupported operating system"
    read -p "Press enter to exit"
    exit 1
fi

# Installs package(s)
sudo zypper in -y btop cpu-x curl dos2unix fastfetch fetchmsttfonts flatpak fontconfig fzf git google-noto-sans-jp-fonts google-noto-sans-kr-fonts grub2-snapper-plugin gsmartcontrol hplip htop inxi memtest86+ nano setroubleshoot shellcheck smartmontools tealdeer yt-dlp zram-generator

# Checks for btrfs partitions
if mount | grep -q "type btrfs"; then
    echo "Detected File System: btrfs"
    # Installs package(s)
    sudo zypper in -y compsize
    
    # Checks for init system
    if ps -p 1 -o comm= | grep -q "systemd"; then
        echo "Detected: systemd"
        # Installs package(s)
        sudo zypper in -y btrfsmaintenance
        
        # Configures system timer(s)
        sudo systemctl disable btrfs-defrag.timer
        sudo systemctl disable btrfs-trim.timer
        sudo systemctl enable btrfs-balance.timer
        sudo systemctl enable btrfs-scrub.timer
        sudo systemctl enable btrfsmaintenance-refresh.path
    fi
else
    echo "No btrfs partitions detected"
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
if [ "$os" = "opensuse-tumbleweed" ] || [ "$os" = "opensuse-slowroll" ]; then
    sudo zypper in -y libreoffice
elif [ "$os" = "opensuse-leap" ]; then
    flatpak install flathub -y org.libreoffice.LibreOffice
else
    echo "Unsupported operating system"
    read -p "Press enter to exit"
    exit 1
fi

# Installs package(s)
flatpak install flathub -y bitwarden spotify vesktop

# Installs package(s)
flatpak install flathub ffmpeg-full gstreamer-vaapi

# Get GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for Intel GPU
if echo "$gpu_info" | grep -iq "intel"; then
    echo "Detected GPU: Intel"
    # Installs package(s)
    flatpak install flathub org.freedesktop.Platform.VAAPI.Intel
else
    echo "No Intel GPU detected"
fi

# Function for user input
get_answer() {
    while true; do
        read -r -p "Install multimedia codecs from Packman? (y/n): " answer
        case "$answer" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Enter a 'y' or 'n'";;
        esac
    done
}

# Checks for answer
if get_answer; then
    # Installs package(s)
    sudo zypper in -y opi
    
    # Installs codecs
    opi codecs
    
    # Installs Brave
    curl -fsS https://dl.brave.com/install.sh | sh
    
    # Installs package(s)
    sudo zypper in -y MozillaFirefox mpv
else
    # Removes package(s)
    sudo zypper rm --clean-deps -y MozillaFirefox

    # Installs package(s)
    flatpak install flathub -y brave io.mpv.Mpv org.mozilla.firefox
fi

# Makes directory(s)
mkdir -pv "$HOME/.config/autostart"
mkdir -pv "$HOME/.config/btop"
mkdir -pv "$HOME/.config/fontconfig"
mkdir -pv "$HOME/.config/htop"
mkdir -pv "$HOME/.config/MangoHud"
mkdir -pv "$HOME/.config/mpv"
mkdir -pv "$HOME/.config/nano"
mkdir -pv "$HOME/.var/app/io.mpv.Mpv/config/mpv"
mkdir -pv "$HOME/Documents/mangohud/logs"

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
    cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud_laptop.conf" "$HOME/.config/MangoHud/"
    cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv_laptop" "$HOME/.config/"
    cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv_laptop" "$HOME/.var/app/io.mpv.Mpv/config/"
    sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram-generator_laptop.conf" /etc/systemd/
    
    # Changes name(s)
    mv -v "$HOME/.config/htop/htoprc_laptop" "$HOME/.config/htop/htoprc"
    mv -v "$HOME/.config/MangoHud/MangoHud_laptop.conf" "$HOME/.config/MangoHud/MangoHud.conf "
    mv -v "$HOME/.config/mpv_laptop" "$HOME/.config/mpv"
    mv -v "$HOME/.var/app/io.mpv.Mpv/config/mpv_laptop" "$HOME/.var/app/io.mpv.Mpv/config/mpv"
    sudo mv -v /etc/systemd/zram-generator_laptop.conf /etc/systemd/zram-generator.conf

    # Checks for file
    if [ -f /etc/default/grub ]; then
        # Adds kernel argument(s)
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=lazy "/' /etc/default/grub
    fi
else
    echo "Detected System: Desktop"
    # Installs package(s)
    sudo zypper in -y mangohud mangohud-32bit selinux-policy-targeted-gaming steam
    flatpak install flathub -y com.github.Matoking.protontricks furmark heroicgameslauncher lact prismlauncher
    flatpak install flathub org.freedesktop.Platform.VulkanLayer.MangoHud

    # Grants flatpaks read-only access to MangoHud's config file
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark 
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
    flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher
    
    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/htoprc" "$HOME/.config/htop/"
    cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud.conf" "$HOME/.config/MangoHud/"
    cp -rv "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.config/"
    cp -rv "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"
    sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram-generator.conf" /etc/systemd/
    
    # Checks for init system
    if ps -p 1 -o comm= | grep -q "systemd"; then
        echo "Detected: systemd"
        # Enables LACT
        sudo systemctl enable --now lactd
    elif ps -p 1 -o comm= | grep -q "runit"; then
        echo "Detected: runit"
        # Enables LACT
        sudo ln -s /etc/sv/lactd /var/service
    fi

    # Checks for AMD GPU
    if echo "$gpu_info" | grep -iq "amd"; then
        echo "Detected GPU: AMD"
        # Checks for file
        if [ -f /etc/default/grub ]; then
            # Adds kernel argument(s)
            sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
        fi
    else
        echo "No AMD GPU detected"
    fi

    # Checks for file
    if [ -f /etc/default/grub ]; then
        # Adds kernel argument(s)
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=full "/' /etc/default/grub
    fi

    # Runs script to install latest Proton GE
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh"
fi

# Detects the desktop environment or window manager, shortens it, then converts it into lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Prints the detected desktop
echo "Detected Desktop: $desktop"

# Conditional execution based on the desktop
case "$desktop" in
    "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
        # Installs package(s)
        sudo zypper in -y redshift transmission-qt
        flatpak install flathub -y flatseal
        
        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift.desktop "$HOME/.config/autostart/"
        ;;
    "budgie"|"cosmic"|"deepin"|"pantheon"|"x-cinnamon")
        # Installs package(s)
        sudo zypper in -y transmission-gtk
        flatpak install flathub -y flatseal
        ;;
    "gnome")
        # Installs package(s)
        sudo zypper in -y gnome-tweaks transmission-gtk
        flatpak install flathub -y extensionmanager flatseal
        
        # Removes package(s)
        sudo zypper rm --clean-deps -y gnome-tour
        
        # Enables experimental variable refresh rate support
        gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate']"
        ;;
    "lxde"|"mate"|"unity"|"xfce")
        # Installs package(s)
        sudo zypper in -y redshift-gtk transmission-gtk
        flatpak install flathub -y flatseal
        
        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME/.config/autostart/"
        ;;
    "lxqt")
        # Installs package(s)
        sudo zypper in -y kclock kweather redshift-gtk transmission-qt
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
        sudo zypper in -y kclock kweather transmission-qt
        ;;
    *)
        echo "Unsupported desktop"
        read -p "Press enter to continue"
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

# Updates GRUB configuration
if command -v update-grub > /dev/null 2>&1; then
    sudo update-grub
elif command -v grub2-mkconfig > /dev/null 2>&1; then
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
elif command -v grub-mkconfig > /dev/null 2>&1; then
    sudo grub-mkconfig -o /boot/grub/grub.cfg
else
    echo "GRUB not detected"
fi

# Checks for init system
if ps -p 1 -o comm= | grep -q "systemd"; then
    echo "Detected: systemd"
    # Reloads systemd manager configuration
    sudo systemctl daemon-reload
fi

# Makes directory(s)
sudo mkdir -pv /etc/sysctl.d

# Loads and applies kernel parameter settings
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Adds package(s) to autostart
cp -v /usr/share/applications/transmission*.desktop "$HOME/.config/autostart/"

# Adds custom bashrc settings
cat "$HOME/Documents/linux_docs/configs/packages/bashrc" >> "$HOME/.bashrc"

# Prints a conclusive message
echo "Setup is now complete"
echo "Reboot to apply all changes"
read -p "Press enter to exit"
