#!/bin/bash

# Ensures that scripts exit immediately when any error occurs, and it treats unset variables and pipeline failures as errors
set -euo pipefail

# Adds Chaotic AUR repository
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo "[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf

# Installs package(s)
sudo pacman -Syu --needed --noconfirm bitwarden btop cpu-x curl discord fastfetch flatpak fzf gsmartcontrol hplip htop libreoffice-fresh memtest86+ mpv smartmontools tealdeer yt-dlp zram-generator

# Installs AUR helper yay if it is not already installed
if ! command -v yay > /dev/null 2>&1; then
    echo "yay is not installed. Installing yay..."
    sudo pacman -S --needed --noconfirm git makepkg
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
else
    echo "yay is already installed"
fi

# Installs package(s)
yay -S linux-lts ttf-ms-win11-auto

# Installs Brave
curl -fsS https://dl.brave.com/install.sh | sh

# Check for Btrfs partitions
if mount | grep -q "type btrfs "; then
    echo "Btrfs partition detected"
    # Installs package(s)
    sudo pacman -S --needed --noconfirm compsize
    yay -S btrfsmaintenance
    
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
flatpak install flathub -y runtime/org.freedesktop.Platform.ffmpeg-full/x86_64/24.08 runtime/org.freedesktop.Platform.GStreamer.gstreamer-vaapi/x86_64/23.08 spotify

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
    
    # Copies config(s)
    cp -v $HOME/Documents/linux_docs/configs/packages/MangoHud_laptop.conf $HOME/.config/MangoHud/
    mv -v $HOME/.config/MangoHud/MangoHud_laptop.conf $HOME/.config/MangoHud/MangoHud.conf 
    
    # Copies config(s)
    sudo cp -v $HOME/Documents/linux_docs/configs/packages/zram-generator_laptop.conf /etc/systemd/
    sudo mv -v /etc/systemd/zram-generator_laptop.conf /etc/systemd/zram-generator.conf
    sudo cp -v $HOME/Documents/linux_docs/configs/packages/99-zram.conf /etc/sysctl.d/
    
    # Checks if GRUB is installed
    if pacman -Q grub &> /dev/null; then
        echo "GRUB is installed"
        # Adds kernel argument(s)
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=lazy"/' /etc/default/grub
    
        # Prints the contents of /etc/default/grub
        cat /etc/default/grub
    
        # Updates grub configuration
        sudo grub2-mkconfig
    else
        echo "GRUB is not installed"
    fi
else
    echo "No battery detected"
    # Installs package(s)
    sudo pacman -S --needed --noconfirm lact lib32-mangohud mangohud prismlauncher steam
    yay -S heroic-games-launcher-bin protontricks
    flatpak install flathub -y furmark runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08

    # Grants flatpaks read-only access to MangoHud's config file
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark
    
    # Makes directory(s)
    mkdir -pv $HOME/.config/htop
    mkdir -pv $HOME/.config/btop
    mkdir -pv $HOME/.config/mpv
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
    
    # Copies config(s)
    cp -v $HOME/Documents/linux_docs/configs/packages/MangoHud.conf $HOME/.config/MangoHud/
    
    # Copies config(s)
    sudo cp -v $HOME/Documents/linux_docs/configs/packages/zram-generator.conf /etc/systemd/
    sudo cp -v $HOME/Documents/linux_docs/configs/packages/99-zram.conf /etc/sysctl.d/
    
    # Enables LACT
    sudo systemctl enable --now lactd
    
    # Checks if GRUB is installed
    if pacman -Q grub &> /dev/null; then
        echo "GRUB is installed"
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
    
        # Prints the contents of /etc/default/grub
        cat /etc/default/grub
    
        # Updates grub configuration
        sudo grub2-mkconfig
    else
        echo "GRUB is not installed"
    fi

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
        sudo pacman -S --needed --noconfirm gnome-tweaks transmission-gtk
        flatpak install flathub -y extension-manager flatseal
        
        # Enables experimental variable refresh rate support
        gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate']"
        ;;
    "plasma")
        # Disables Baloo (KDE file indexer)
        balooctl6 disable
        
        # Installs package(s)
        sudo pacman -S --needed --noconfirm kclock kweather transmission-qt
        ;;
    "lxqt")
        # Installs package(s)
        sudo pacman -S --needed --noconfirm kclock kweather redshift transmission-qt
        flatpak install flathub -y flatseal
        
        # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/redshift.conf $HOME/.config/
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop $HOME/.config/autostart/
        ;;
    "lxde")
        # Installs package(s)
        sudo pacman -S --needed --noconfirm redshift transmission-gtk
        flatpak install flathub -y flatseal
        
        # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/redshift.conf $HOME/.config/
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop $HOME/.config/autostart/
        ;;
    "mate")
        # Installs package(s)
        sudo pacman -S --needed --noconfirm redshift transmission-gtk
        flatpak install flathub -y flatseal
        
        # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/redshift.conf $HOME/.config/
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop $HOME/.config/autostart/
        ;;
    "xfce")
        # Installs package(s)
        sudo pacman -S --needed --noconfirm redshift transmission-gtk
        flatpak install flathub -y flatseal
        
        # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/redshift.conf $HOME/.config/
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop $HOME/.config/autostart/
        ;;
    "x-cinnamon")
        # Installs package(s)
        sudo pacman -S --needed --noconfirm transmission-gtk
        flatpak install flathub -y flatseal
        ;;
    "budgie")
        # Installs package(s)
        sudo pacman -S --needed --noconfirm transmission-gtk
        flatpak install flathub -y flatseal
        ;;
    *)
        echo "Nothing to do for $desktop_env"
        ;;
esac

# Adds package(s) to autostart
cp -v /usr/share/applications/transmission*.desktop $HOME/.config/autostart/

# Set paccache to only retain one past version of packages
sudo paccache -rk1

# Enables timer to discard unused packages weekly
sudo systemctl enable --now paccache.timer

# Reloads systemd manager configuration
sudo systemctl daemon-reload

# Loads and applies kernel parameter settings from the 99-zram.conf
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Lists files in the autostart directory
ls $HOME/.config/autostart/

# Adds aliases to bash profile
cat $HOME/Documents/linux_docs/configs/aliases/aliases_arch.txt >> $HOME/.bashrc

# Prints a conclusive message to end the script
echo "Setup is now complete. Reboot to apply all changes."
