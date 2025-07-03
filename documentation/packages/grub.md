# GRUB

## Show/Hide GRUB menu on boot

```bash
sudo grub2-editenv - unset menu_auto_hide
sudo grub2-editenv - set menu_auto_hide=false
```

## Update GRUB

- Conventional

```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

- Debian/Debian-based

```bash
sudo update-grub
```
