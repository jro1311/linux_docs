#!/usr/bin/env bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Updates system
sudo xbps-install -u -y

# Installs package(s)
sudo xbps-install -y btop cabextract CPU-X curl dos2unix faac fastfetch firefox flac flatpak fontconfig fzf git hplip htop inxi memtest86+ mpv nano pciutils smartmontools tealdeer x264 x265 yt-dlp zramen

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
flatpak install flathub -y bitwarden discordapp runtime/org.freedesktop.Platform.ffmpeg-full/x86_64/24.08 runtime/org.freedesktop.Platform.GStreamer.gstreamer-vaapi/x86_64/23.08 app/org.libreoffice.LibreOffice/x86_64/stable spotify

# Gets GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for Intel GPU
if echo "$gpu_info" | grep -i "intel" &> /dev/null; then
    echo "Detected GPU: Intel"
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
cp -v "$HOME/Documents/linux_docs/configs/packages/btop.conf" "$HOME/.config/btop/"
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
    cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud_laptop.conf" "$HOME/.config/MangoHud/"
    cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv_laptop" "$HOME/.config/"
    cp -vr "$HOME/Documents/linux_docs/configs/packages/mpv_laptop" "$HOME/.var/app/io.mpv.Mpv/config/"
    
    # Changes name(s)
    mv -v "$HOME/.config/htop/htoprc_laptop" "$HOME/.config/htop/htoprc"
    mv -v "$HOME/.config/MangoHud/MangoHud_laptop.conf" "$HOME/.config/MangoHud/MangoHud.conf "
    mv -v "$HOME/.config/mpv_laptop" "$HOME/.config/mpv"
    mv -v "$HOME/.var/app/io.mpv.Mpv/config/mpv_laptop" "$HOME/.var/app/io.mpv.Mpv/config/mpv"
    
    # Makes zram swap device
    sudo zramen make -a lz4 -s 100

    # Adds kernel argument(s)
    sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=lazy"/' /etc/default/grub
else
    echo "Detected System: Desktop"
    # Installs package(s)
    sudo xbps-install -y LACT MangoHud MangoHud-32bit steam
    flatpak install flathub -y furmark heroicgameslauncher runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08 prismlauncher com.github.Matoking.protontricks/x86_64/stable

    # Grants flatpaks read-only access to MangoHud's config file
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
    flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher

    # Copies config(s)
    cp -v "$HOME/Documents/linux_docs/configs/packages/htoprc" "$HOME/.config/htop/"
    cp -v "$HOME/Documents/linux_docs/configs/packages/MangoHud.conf" "$HOME/.config/MangoHud/"
    cp -rv "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.config/"
    cp -rv "$HOME/Documents/linux_docs/configs/packages/mpv" "$HOME/.var/app/io.mpv.Mpv/config/"

    # Enables LACT
    sudo ln -s /etc/sv/lactd /var/service

    # Gets GPU information
    gpu_info=$(lspci | grep -E "VGA|3D")

    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
        echo "Detected GPU: AMD"
        # Installs package(s)
        sudo xbps-install -y ROCm-SMI

        # Adds kernel argument(s)
        sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ amdgpu.ppfeaturemask=0xffffffff "/' /etc/default/grub
    else
        echo "No AMD GPU detected"
    fi
    
    # Makes zram swap device
    sudo zramen make -a zstd -s 100

    # Adds kernel argument(s)
    sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ preempt=full"/' /etc/default/grub

    # Runs script to install latest Proton GE
    chmod +x "$HOME/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh"
    "$HOME/Documents/linux_docs/scripts/packages/terminal/proton_ge_install.sh"
fi

# Detects the desktop environment and stores in a variable, then converts it into lowercase
desktop_env=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Prints the detected desktop environment
echo "Detected: $desktop_env"

# Conditional execution based on the desktop environment
case "$desktop_env" in
    "xfce")
        # Installs package(s)
        sudo xbps-install -y redshift-gtk transmission-gtk
        flatpak install flathub -y flatseal

        # Copies config(s)
        cp -v "$HOME/Documents/linux_docs/configs/packages/redshift.conf" "$HOME/.config/"
        
        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop "$HOME/.config/autostart/"
        ;;
    *)
        echo "Unsupported desktop environment"
        read -p "Press enter to continue"
        ;;
esac

# Updates GRUB configuration
sudo update-grub

# Loads and applies kernel parameter settings from the 99-zram.conf
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Prints the contents of /etc/default/grub
cat /etc/default/grub

# Adds package(s) to autostart
cp -v /usr/share/applications/transmission*.desktop "$HOME/.config/autostart/"

# Adds aliases to bash profile
cat "$HOME/Documents/linux_docs/configs/aliases/dnf_aliases.txt" >> "$HOME/.bashrc"

# Prints a conclusive message
echo "Setup is now complete"
echo "Reboot to apply all changes"
read -p "Press enter to exit"
