# GRUB
## Update GRUB
- Conventional:

    ```bash
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    ```
    
- Conventional (old):

    ```bash
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    ```

- Alternative (e.g., Debian):

    ```bash
    sudo update-grub
    ```

## Show/Hide GRUB menu on boot

```bash
sudo grub2-editenv - unset menu_auto_hide
sudo grub2-editenv - set menu_auto_hide=false
```
