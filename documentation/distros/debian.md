# Nala 

sudo apt install -y nala

# Multimedia Codecs and Microsoft Fonts

sudo apt install -y software-properties-common
sudo add-apt-repository multiverse  
sudo apt install -y libavcodec-extra ttf-mscorefonts-installer

# Update grub

sudo update-grub

# LightDM 

sudo nano /etc/lightdm/lightdm.conf

## Enable user list

[Seat:*]
greeter-hide-users=false

## Enable autologin

[Seat:*]
autologin-user=
autologin-user-timeout=0

