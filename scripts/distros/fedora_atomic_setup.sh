#!/bin/bash

# Sets the script to exit immediately when any error, unset variable, or pipeline failure occurs
set -euo pipefail

# Uninstalls package(s)
rpm-ostree override remove firefox firefox-langpacks

# Installs package(s)
rpm-ostree install btrfsmaintenance

# Creates a toolbox container and installs packages inside of it
toolbox create
toolbox enter -- bash -c "
    dnf install -y btop fastfetch fzf htop rocm-smi tealdeer yt-dlp && \
    echo 'Toolbox packages installed successfully'
"

# Installs Microsoft fonts
chmod +x $HOME/Documents/linux_docs/scripts/packages/terminal/fedora_atomic_mscorefonts_install.sh
$HOME/Documents/linux_docs/scripts/packages/terminal/fedora_atomic_mscorefonts_install.sh

# Adds current user to wheel group if they are not already
sudo usermod -aG wheel $USER

# Disables Fedora flatpak repositority
flatpak remote-modify --disable fedora

# Adds Flathub repository
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Installs package(s)
flatpak install flathub -y bitwarden brave cpu-x discordapp runtime/org.freedesktop.Platform.ffmpeg-full/x86_64/24.08 app/org.mozilla.firefox/x86_64/stable runtime/org.freedesktop.Platform.GStreamer.gstreamer-vaapi/x86_64/23.08 app/org.libreoffice.LibreOffice/x86_64/stable app/io.mpv.Mpv/x86_64/stable spotify app/com.transmissionbt.Transmission/x86_64/stable

# Gets GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

# Checks for Intel GPU
if echo "$gpu_info" | grep -i "intel" &> /dev/null; then
    echo "Intel GPU detected"
    # Install package(s)
    flatpak install flathub -y runtime/org.freedesktop.Platform.VAAPI.Intel/x86_64/24.08
else
    echo "No Intel GPU detected"
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

# Checks for battery
if check_battery; then
    echo "Battery detected"
    # Makes directory(s)
    mkdir -pv $HOME/.config/htop
    mkdir -pv $HOME/.config/btop
    mkdir -pv $HOME/.var/app/io.mpv.Mpv/config/mpv
    mkdir -pv $HOME/.config/MangoHud
    mkdir -pv $HOME/Documents/MangoHud/logs
    
    # Copies config(s)
    cp -v $HOME/Documents/linux_docs/configs/packages/nanorc $HOME/.config/
    cp -v $HOME/Documents/linux_docs/configs/packages/htoprc_laptop $HOME/.config/htop/
    cp -v $HOME/Documents/linux_docs/configs/packages/btop.conf $HOME/.config/btop/
    cp -vr $HOME/Documents/linux_docs/configs/packages/mpv_laptop $HOME/.config/
    cp -vr $HOME/Documents/linux_docs/configs/packages/mpv_laptop $HOME/.var/app/io.mpv.Mpv/config/
    cp -v $HOME/Documents/linux_docs/configs/packages/MangoHud_laptop.conf $HOME/.config/MangoHud/
    sudo cp -v $HOME/Documents/linux_docs/configs/packages/zram-generator_laptop.conf /etc/systemd/
    sudo cp -v $HOME/Documents/linux_docs/configs/packages/99-zram.conf /etc/sysctl.d/
    
    # Changes name(s)
    mv -v $HOME/.config/nanorc $HOME/.config/.nanorc
    mv -v $HOME/.config/htop/htoprc_laptop $HOME/.config/htop/htoprc
    mv -v $HOME/.config/mpv_laptop $HOME/.config/mpv
    mv -v $HOME/.var/app/io.mpv.Mpv/config/mpv_laptop $HOME/.var/app/io.mpv.Mpv/config/mpv
    mv -v $HOME/.config/MangoHud/MangoHud_laptop.conf $HOME/.config/MangoHud/MangoHud.conf 
    sudo mv -v /etc/systemd/zram-generator_laptop.conf /etc/systemd/zram-generator.conf

    # Adds kernel argument(s)
    rpm-ostree kargs --append=preempt=lazy
else
    echo "No battery detected"
    # Installs package(s)
    flatpak install flathub -y furmark heroicgameslauncher lact runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08 mangojuice prismlauncher com.valvesoftware.Steam.CompatibilityTool.Proton-GE com.github.Matoking.protontricks/x86_64/stable app/com.valvesoftware.Steam/x86_64/stable
    
    # Grants flatpaks read-only access to MangoHud's config file
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.geeks3d.furmark 
    flatpak override --user --filesystem=xdg-config/MangoHud:ro com.heroicgameslauncher.hgl
    flatpak override --user --filesystem=xdg-config/MangoHud:ro org.prismlauncher.PrismLauncher
    
    # Makes directory(s)
    mkdir -pv $HOME/.config/htop
    mkdir -pv $HOME/.config/btop
    mkdir -pv $HOME/.var/app/io.mpv.Mpv/config/mpv
    mkdir -pv $HOME/.config/MangoHud
    mkdir -pv $HOME/Documents/MangoHud/logs
    
    # Copies config(s)
    cp -v $HOME/Documents/linux_docs/configs/packages/nanorc $HOME/.config/
    cp -v $HOME/Documents/linux_docs/configs/packages/htoprc $HOME/.config/htop/
    cp -v $HOME/Documents/linux_docs/configs/packages/btop.conf $HOME/.config/btop/
    cp -vr $HOME/Documents/linux_docs/configs/packages/mpv $HOME/.var/app/io.mpv.Mpv/config/
    cp -v $HOME/Documents/linux_docs/configs/packages/MangoHud.conf $HOME/.config/MangoHud/
    sudo cp -v $HOME/Documents/linux_docs/configs/packages/zram-generator.conf /etc/systemd/
    sudo cp -v $HOME/Documents/linux_docs/configs/packages/99-zram.conf /etc/sysctl.d/
    
    # Changes name(s)
    mv -v $HOME/.config/nanorc $HOME/.config/.nanorc
    
    # Enables LACT
    sudo systemctl enable --now lactd

    # Checks for AMD GPU
    if echo "$gpu_info" | grep -i "amd" &> /dev/null; then
        echo "AMD GPU detected"
        # Adds kernel argument(s)
        rpm-ostree kargs --append=amdgpu.ppfeaturemask=0xffffffff
    else
        echo "No AMD GPU detected"
    fi

    # Adds kernel argument(s)
    rpm-ostree kargs --append=preempt=full
fi

# Detects the desktop environment and stores in a variable, then converts it into lowercase
desktop_env=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | cut -d ':' -f1 | tr '[:upper:]' '[:lower:]')

# Prints the detected desktop environment
echo "Detected: $desktop_env"

# Conditional execution based on the desktop environment
case "$desktop_env" in
    "gnome")
        # Installs package(s)
        rpm-ostree install gnome-tweaks
        flatpak install flathub -y extensionmanager flatseal
        
        # Uninstalls package(s)
        rpm-ostree remove gnome-tour

        # Enables experimental variable refresh rate support
        gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate']"
        ;;
    "plasma")
        # Disables Baloo (KDE file indexer)
        balooctl6 disable
        ;;
    "lxqt")
        # Installs package(s)
        rpm-ostree install redshift-gtk
        flatpak install flathub -y flatseal

        # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/redshift.conf $HOME/.config/

        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop $HOME/.config/autostart/
        ;;
    "lxde")
        # Installs package(s)
        rpm-ostree install redshift-gtk
        flatpak install flathub -y flatseal

        # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/redshift.conf $HOME/.config/

        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop $HOME/.config/autostart/
        ;;
    "mate")
        # Installs package(s)
        rpm-ostree install redshift-gtk
        flatpak install flathub -y flatseal

        # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/redshift.conf $HOME/.config/

        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop $HOME/.config/autostart/
        ;;
    "xfce")
        # Installs package(s)
        rpm-ostree install redshift-gtk
        flatpak install flathub -y flatseal

       # Copies config(s)
        cp -v $HOME/Documents/linux_docs/configs/packages/redshift.conf $HOME/.config/

        # Adds package(s) to autostart
        cp -v /usr/share/applications/redshift-gtk.desktop $HOME/.config/autostart/
        ;;
    "x-cinnamon")
        # Installs package(s)
        flatpak install flathub -y flatseal
        ;;
    "budgie")
        # Installs package(s)
        flatpak install flathub -y flatseal
        ;;
    *)
        echo "Nothing to do for $desktop_env"
        ;;
esac

# Adds package(s) to autostart
cp -v /var/lib/flatpak/exports/share/applications/com.transmissionbt.Transmission.desktop $HOME/.config/autostart/

# Reloads systemd manager configuration
sudo systemctl daemon-reload

# Loads and applies kernel parameter settings from the 99-zram.conf
sudo sysctl -p /etc/sysctl.d/99-zram.conf

# Lists files in the autostart directory
ls $HOME/.config/autostart/

# Adds aliases to bash profile
cat $HOME/Documents/linux_docs/configs/aliases/aliases_fedora.txt >> $HOME/.bashrc

# Prints a conclusive message to end the script
echo "Setup is now complete. Reboot to apply all changes."
