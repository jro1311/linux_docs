# Installs Microsoft fonts
sudo dnf install -y cabextract curl fontconfig xorg-x11-font-utils
sudo dnf install https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# Adds flathub repository if it doesn't already exist
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# RPM Fusion
https://rpmfusion.org/

## RPM Fusion Multimedia
https://rpmfusion.org/Howto/Multimedia

# Unique aliases
## Updates system and flatpaks
alias update='sudo dnf upgrade && flatpak update'

# Removes unneeded packages and flatpaks
alias clean='sudo dnf autoremove && flatpak uninstall --unused'

# Lists locked packages
dnf versionlock list

# Locks KDE Plasma version
sudo dnf versionlock add @kde-desktop-environment

# Unlocks KDE Plasma version
sudo dnf versionlock delete @kde-desktop-environment

# Stop Firefox from resetting home page
    - sudo nano /usr/lib64/firefox/browser/defaults/preferences/firefox-redhat-default-prefs.js
    - delete line with "browser.startup.homepage"

# Grub

## Show grub menu on boot
sudo grub2-editenv - unset menu_auto_hide

### Undo previous changes
sudo grub2-editenv - set menu_auto_hide=false

## Update grub
sudo grub2-mkconfig

