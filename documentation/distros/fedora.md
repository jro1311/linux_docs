# Multimedia Codecs and Microsoft Fonts

## Enables access to both the free and the nonfree RPM Fusion repositories
sudo dnf upgrade -y && sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

## Switches from default openh264 library to RPM Fusion version
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1 -y

## Enables users to install packages from RPM Fusion using Gnome Software/KDE Discover
sudo dnf update @core -y

## Switches to the RPM Fusion provided ffmpeg build
sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y

## Installs additional codecs
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y

## Installs package(s)
sudo dnf install -y pciutils

## Gets GPU information
gpu_info=$(lspci | grep -E "VGA|3D")

## Check for Intel GPU
if echo "$gpu_info" | grep -i "intel" &> /dev/null; then
    echo "Intel GPU detected"
    # Installs Intel-specific drivers
    flatpak install flathub -y runtime/org.freedesktop.Platform.VAAPI.Intel/x86_64/24.08
    
    # Installs Intel-specific drivers (recent)
    sudo dnf install -y intel-media-driver
    
    # Installs Intel-specific drivers (older)
    sudo dnf install libva-intel-driver
    
## Checks for AMD GPU
elif echo "$gpu_info" | grep -i "amd" &> /dev/null; then
    echo "AMD GPU detected"
    # Installs AMD-specific drivers
    sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
    sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
    sudo dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
    sudo dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
    
## Checks for Nvidia GPU
elif echo "$gpu_info" | grep -i "nvidia" &> /dev/null; then
    echo "Nvidia GPU detected"
    # Installs NVIDIA-specific drivers
    sudo dnf install -y libva-nvidia-driver.{i686,x86_64}
else
    echo "No Intel, AMD, or Nvidia GPU detected"
fi

## Checks for optical drive
if [ -e /dev/sr0 ]; then
    echo "Optical drive detected"
    # Enables playback of DVDs
    sudo dnf install -y rpmfusion-free-release-tainted
    sudo dnf install -y libdvdcss
else
    echo "No optical drive detected"
fi

## Enables various firmwares
sudo dnf install -y rpmfusion-nonfree-release-tainted
sudo dnf --repo=rpmfusion-nonfree-tainted install -y "*-firmware"

## Installs package(s)
sudo dnf install -y https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# GRUB

## Show GRUB menu on boot

sudo grub2-editenv - unset menu_auto_hide

### Undo previous command

sudo grub2-editenv - set menu_auto_hide=false

## Update GRUB

sudo grub2-mkconfig

