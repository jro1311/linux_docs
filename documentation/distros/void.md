# Codecs

sudo xbps-install -u -y && sudo xbps-install -y faac flac x264 x265

## Checks for optical drive

if [ -e /dev/sr0 ]; then
    echo "Optical drive detected"
    # Installs package(s)
    sudo xbps-install -y libdvdcss libdvdnav libdvdread
else
    echo "No optical drive detected"
fi

# Microsoft Fonts

N/A

# Update GRUB

sudo update-grub

# zRAM

sudo xbps-install -y zramen
sudo zramen make -a zstd -s 100
sudo cp -v "$HOME/Documents/linux_docs/configs/packages/99-zram.conf" /etc/sysctl.d/
sudo sysctl -p /etc/sysctl.d/99-zram.conf
