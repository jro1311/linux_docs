#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for package manager
if ! command -v dnf > /dev/null 2>&1; then
    echo "Unsupported package manager"
    read -p "Press enter to exit"
    exit 1
fi

# Removes package(s)
sudo dnf remove -y chromium libreoffice*

# Upgrades system
sudo dnf upgrade -y

# Installs package(s)
sudo dnf install -y btop cabextract cpu-x curl dos2unix faac fastfetch firefox flac flatpak fonts-ttf-japanese fonts-ttf-korean fontconfig fzf git hplip htop inxi lib64dca0 lib64xvid4 memtest86+ mpv nano pciutils smartmontools tealdeer x264 x265 yt-dlp zram-generator

# Installs Brave
curl -fsS https://dl.brave.com/install.sh | sh

# Checks for optical drive
if [ -e /dev/sr0 ]; then
    echo "Optical drive detected"
    # Installs package(s)
    sudo dnf install -y lib64dvdcss lib64dvdnav4 lib64dvdread
else
    echo "No optical drive detected"
fi

# Checks for btrfs partitions
if mount | grep -q "type btrfs"; then
    echo "Detected File System: btrfs"
    # Checks for init system
    if ps -p 1 -o comm= | grep -q "systemd"; then
        echo "Detected: systemd"
        # Installs package(s)
        sudo dnf install -y btrfsmaintenance

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
flatpak install flathub -y bitwarden org.libreoffice.LibreOffice spotify vesktop

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

    # Adds kernel argument(s)
    sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=lazy"/' /etc/default/grub
else
    echo "Detected System: Desktop"
    # Installs package(s)
    sudo dnf install -y lact mangohud steam
    flatpak install flathub -y com.github.Matoking.protontricks furmark heroicgameslauncher prismlauncher
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
        # Installs package(s)
        sudo dnf install -y rocm-smi

        # Checks for file
        if [ -f /etc/default/grub ]; then
            # Adds kernel argument(s)
            sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
        fi
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
        sudo dnf install -y redshift transmission-qt
        flatpak install flathub -y flatseal

        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift.desktop "$HOME/.config/autostart/"
        ;;
    "budgie"|"cosmic"|"deepin"|"pantheon"|"x-cinnamon")
        # Installs package(s)
        sudo dnf install -y transmission-gtk
        flatpak install flathub -y flatseal
        ;;
    "gnome")
        # Installs package(s)
        sudo dnf install -y gnome-tweaks transmission-gtk
        flatpak install flathub -y extensionmanager flatseal

        # Removes package(s)
        sudo dnf remove -y gnome-tour

        # Enables experimental variable refresh rate support
        gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate']"
        ;;
    "lxde"|"mate"|"unity"|"xfce")
        # Installs package(s)
        sudo dnf install -y redshift-gtk transmission-gtk
        flatpak install flathub -y flatseal

        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME/.config/autostart/"
        ;;
    "lxqt")
        # Installs package(s)
        sudo dnf install -y kclock kweather redshift-gtk transmission-qt
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
        sudo dnf install -y kclock kweather transmission-qt
        ;;
    *)
        echo "Unsupported desktop"
        read -p "Press enter to continue"
        ;;
esac

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
