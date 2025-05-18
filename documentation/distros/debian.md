# Installs nala (command-line frontend for apt)
sudo apt -y install nala

# Installs flatpak
sudo nala install -y flatpak

# Adds flathub repository if it doesn't already exist
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Installs package for managing software repositories from the command line
sudo nala install -y software-properties-common

# Adds contrib and non-free repositories
sudo apt-add-repository -y contrib non-free-firmware

# Adds Debian backports repository
echo "deb http://deb.debian.org/debian bookworm-backports main" | sudo tee -a /etc/apt/sources.list && sudo apt update

# Installs Microsoft fonts
sudo nala install -y ttf-mscorefonts-installer

# Installs codecs
sudo nala install -y libavcodec-extra

# Installs Wine
sudo nala install -y wine-installer

# Unique aliases
## Updates system and flatpaks
alias update='sudo nala upgrade && flatpak update'

## Removes unneeded dependencies and configuration files
alias clean='sudo nala clean && sudo nala autopurge && flatpak uninstall --unused'

# LightDM 
sudo nano /etc/lightdm/lightdm.conf

## Enable user list
[Seat:*]
greeter-hide-users=false

## Enable autologin
[Seat:*]
autologin-user=
autologin-user-timeout=0

