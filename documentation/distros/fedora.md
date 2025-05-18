# Codecs

## RPM Fusion
- https://rpmfusion.org
- https://rpmfusion.org/Howto/Multimedia

# Grub

## Show grub menu on boot
sudo grub2-editenv - unset menu_auto_hide

### Undo previous command
sudo grub2-editenv - set menu_auto_hide=false

## Update grub
sudo grub2-mkconfig

