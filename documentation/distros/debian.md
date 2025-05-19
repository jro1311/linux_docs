# Codecs

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

