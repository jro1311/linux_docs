# Codecs

sudo apt install -y software-properties-common
sudo add-apt-repository multiverse  
sudo apt install -y libavcodec-extra

# LightDM 

sudo nano /etc/lightdm/lightdm.conf

## Enable user list

[Seat:*]
greeter-hide-users=false

## Enable autologin

[Seat:*]
autologin-user=
autologin-user-timeout=0

# Microsoft Fonts

sudo nala install -y ttf-mscorefonts-installer

# Nala 

sudo apt install -y nala

# Update GRUB

sudo update-grub
