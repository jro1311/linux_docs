# RPM Fusion

- https://rpmfusion.org
- https://rpmfusion.org/Howto/Multimedia

# Microsoft Fonts

sudo dnf install -y https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# Grub

## Show grub menu on boot

sudo grub2-editenv - unset menu_auto_hide

### Undo previous command

sudo grub2-editenv - set menu_auto_hide=false

## Update grub

sudo grub2-mkconfig

