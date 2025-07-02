#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Checks for package manager
if ! command -v pacman > /dev/null 2>&1; then
    echo "Unsupported package manager"
    read -p "Press enter to exit"
    exit 1
fi

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
fi

# Installs package(s)
sudo pacman -Syu --needed --noconfirm btop cpu-x curl dos2unix fastfetch firefox flatpak fontconfig fzf git gsmartcontrol hplip htop inxi libreoffice-fresh memtest86+ mpv nano shellcheck smartmontools tealdeer yt-dlp zram-generator

# Checks for AUR helper
if command -v paru > /dev/null 2>&1; then
    # Installs package(s)
    paru -S linux-lts nano-syntax-highlighting ttf-ms-win11-auto
elif command -v yay > /dev/null 2>&1; then
    # Installs package(s)
    yay -S linux-lts nano-syntax-highlighting ttf-ms-win11-auto
else
    # Installs yay
    sudo pacman -S --needed --noconfirm base-devel git makepkg
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
    
    # Installs package(s)
    yay -S linux-lts nano-syntax-highlighting ttf-ms-win11-auto
fi

# Installs Brave
curl -fsS https://dl.brave.com/install.sh | sh

# Checks for btrfs partitions
if mount | grep -q "type btrfs"; then
    echo "Detected File System: btrfs"
    # Installs package(s)
    sudo pacman -S --needed --noconfirm compsize
    
    # Checks for init system
    if ps -p 1 -o comm= | grep -q "systemd"; then
        echo "Detected: systemd"
        # Checks for paru
        if command -v paru > /dev/null 2>&1; then
            # Installs package(s)
            paru -S btrfsmaintenance
        elif command -v yay > /dev/null 2>&1; then
            # Installs package(s)
            yay -S btrfsmaintenance
        fi
    
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
    sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram-generator_laptop.conf" /etc/systemd/
    
    # Changes name(s)
    mv -v "$HOME/.config/htop/htoprc_laptop" "$HOME/.config/htop/htoprc"
    mv -v "$HOME/.config/mpv_laptop" "$HOME/.config/mpv"
    mv -v "$HOME/.var/app/io.mpv.Mpv/config/mpv_laptop" "$HOME/.var/app/io.mpv.Mpv/config/mpv"
    sudo mv -v /etc/systemd/zram-generator_laptop.conf /etc/systemd/zram-generator.conf
    
    # Checks for GRUB
    if pacman -Qs grub > /dev/null 2>&1; then
        echo "Detected Bootloader: GRUB"
        # Adds kernel argument(s)
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=lazy "/' /etc/default/grub
    else
        echo "GRUB not detected"
    fi
else
    echo "Detected System: Desktop"
    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/htoprc" "$HOME/.config/htop/"
    cp -rv "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.config/"
    cp -rv "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"
    sudo cp -v "$HOME/Documents/linux_docs/configs/packages/zram-generator.conf" /etc/systemd/
    
    # Checks for GRUB
    if pacman -Qs grub > /dev/null 2>&1; then
        echo "Detected Bootloader: GRUB"
        # Adds kernel argument(s)
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=full "/' /etc/default/grub
    else
        echo "GRUB not detected"
    fi
fi

# Detects the desktop environment or window manager, shortens it, then converts it into lowercase
desktop=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Prints the detected desktop
echo "Detected Desktop: $desktop"

# Conditional execution based on the desktop
case "$desktop" in
    "awesome"|"bspwm"|"dwm"|"enlightenment"|"fluxbox"|"hyprland"|"i3"|"icewm"|"jwm"|"miracle-wm"|"openbox"|"qtile"|"sway"|"xmonad")
        # Installs package(s)
        sudo pacman -S --needed --noconfirm redshift transmission-qt
        flatpak install flathub -y flatseal
        
        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift.desktop "$HOME/.config/autostart/"
        ;;
    "budgie"|"cosmic"|"deepin"|"pantheon"|"x-cinnamon")
        # Installs package(s)
        sudo pacman -S --needed --noconfirm transmission-gtk
        flatpak install flathub -y flatseal
        ;;
    "gnome")
        # Installs package(s)
        sudo pacman -S --needed --noconfirm gnome-tweaks transmission-gtk
        flatpak install flathub -y extension-manager flatseal
        
        # Enables experimental variable refresh rate support
        gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate']"
        ;;
    "lxde"|"mate"|"unity"|"xfce")
        # Installs package(s)
        sudo pacman -S --needed --noconfirm redshift transmission-gtk
        flatpak install flathub -y flatseal
        
        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME/.config/autostart/"
        ;;
    "lxqt")
        # Installs package(s)
        sudo pacman -S --needed --noconfirm kclock kweather redshift transmission-qt
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
        sudo pacman -S --needed --noconfirm kclock kweather transmission-qt
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

# Removes all cached versions of packages except the latest and one prior version
sudo paccache -rk1

# Checks for init system
if ps -p 1 -o comm= | grep -q "systemd"; then
    echo "Detected: systemd"
    # Enables timer to discard unused packages weekly
    sudo systemctl enable --now paccache.timer
    
    # Reloads systemd manager configuration
    sudo systemctl daemon-reload
fi

# Makes directory(s)
sudo mkdir -pv /etc/sysctl.d

# Loads and applies kernel parameter settings
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Adds custom bashrc settings
cat "$HOME/Documents/linux_docs/configs/packages/bashrc" >> "$HOME/.bashrc"

# Prints a conclusive message
echo "Setup is now complete"
echo "Reboot to apply all changes"
read -p "Press enter to exit"
