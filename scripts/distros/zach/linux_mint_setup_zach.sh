#!/bin/bash

# Ensures that scripts exit immediately when any error occurs, and it treats unset variables and pipeline failures as errors
set -euo pipefail

# Refreshes package repositories and installs package(s)
sudo apt update && sudo apt install -y nala

# Uninstalls package(s)
sudo nala remove -y libreoffice*

# Installs package(s)
sudo nala upgrade -y && sudo nala install -y btop cpu-x curl flatpak fzf gsmartcontrol htop memtest86+ mint-meta-codecs mpv neofetch smartmontools systemd-zram-generator tealdeer transmission-gtk ttf-mscorefonts-installer yt-dlp

# Installs Brave
curl -fsS https://dl.brave.com/install.sh | sh

# Check for Btrfs partitions
if mount | grep -q "type btrfs "; then
    echo "Btrfs partition detected"
    # Installs package(s)
    sudo nala install -y btrfs-compsize btrfsmaintenance

    # Configures system timer(s)
    sudo systemctl disable btrfs-defrag.timer
    sudo systemctl disable btrfs-trim.timer
    sudo systemctl enable btrfs-balance.timer
    sudo systemctl enable btrfs-scrub.timer
    sudo systemctl enable btrfsmaintenance-refresh.path
else
    echo "No Btrfs partitions detected"
fi

# Adds Flathub repository
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Installs package(s)
flatpak install flathub -y discordapp runtime/org.freedesktop.Platform.ffmpeg-full/x86_64/24.08 flatseal runtime/org.freedesktop.Platform.GStreamer.gstreamer-vaapi/x86_64/23.08 app/org.libreoffice.LibreOffice/x86_64/stable

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

# Makes autostart directory
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
    
    # Adds kernel argument(s)
    sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=lazy"/' /etc/default/grub
else
    echo "No battery detected"
    # Installs package(s)
    sudo nala install -y mangohud steam-installer
    flatpak install flathub -y furmark lact runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08 prismlauncher com.github.Matoking.protontricks/x86_64/stable
    
    # Grants flatpaks read-only access to MangoHud's config file
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark
    flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher
    
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
    "x-cinnamon")
        ;;
    "mate")
        # Installs package(s)
        sudo nala install -y redshift-gtk

        # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/redshift.conf $HOME/.config/

        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop $HOME/.config/autostart/
        ;;
    "xfce")
        # Installs package(s)
        sudo nala install -y redshift-gtk

        # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/redshift.conf $HOME/.config/

        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop $HOME/.config/autostart/
        ;;
    *)
        echo "Nothing to do for $desktop_env"
        ;;
esac

# Updates grub configuration
sudo update-grub

# Reloads systemd manager configuration
sudo systemctl daemon-reload

# Loads and applies kernel parameter settings from the 99-zram.conf
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Prints the contents of /etc/default/grub
cat /etc/default/grub

# Lists files in the autostart directory
ls $HOME/.config/autostart/

# Adds aliases to bash profile
cat $HOME/Documents/linux_docs/configs/aliases/aliases_linux_mint.md >> $HOME/.bashrc

# Prints a conclusive message to end the script
echo "Setup is now complete. Reboot to apply all changes."
