# Multimedia Codecs

## Installs package(s)
sudo dnf upgrade -y && sudo dnf install -y faac flac lib64dca0 lib64xvid4 x264 x265

## Checks for optical drive
if [ -e /dev/sr0 ]; then
    echo "Optical drive detected"
    # Installs package(s)
    sudo dnf install -y lib64dvdcss2
else
    echo "No optical drive detected"
fi

# Update GRUB

sudo grub2-mkconfig

