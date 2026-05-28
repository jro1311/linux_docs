# GRUB
## Options
- **GRUB_TIMEOUT**=`[-1|0-x]`
    - Controls how long GRUB waits before booting the default entry
    - `-1`: wait indefinitely (menu always shown, no auto‑boot)
    - `0`: no delay (auto‑boot immediately unless overridden by hidden‑menu logic)
- **GRUB_RECORDFAIL_TIMEOUT**=`[-1|0-x]`
    - Timeout used only when the previous boot failed
    - `-1`: wait indefinitely on failure
    - If unset, GRUB falls back to `GRUB_TIMEOUT`
- **GRUB_TIMEOUT_STYLE**=`[menu|countdown|hidden]`
    - `menu`
        - always show the menu
        - wait for `GRUB_TIMEOUT`
    - `countdown`
        - shows a numeric countdown
        - menu appears only after timeout expires
    - `hidden`
        - hides menu
        - only show it if `ESC`, `SHIFT`, or `F4` is pressed during the timeout window
        - hidden‑menu logic is disabled if `GRUB_TIMEOUT=-1`
- **GRUB_FORCE_HIDDEN_MENU**=`[true|false]`
    - Forces the menu to stay hidden regardless of `GRUB_TIMEOUT_STYLE`
    - Only shows the menu if `ESC`, `SHIFT`, or `F4` is pressed early in boot
- **GRUB_DISABLE_SUBMENU**=`[true|false]`
    - `true`: list all kernel versions directly in the top‑level menu
    - `false`: group older kernels under a submenu
    
## Edit

```bash
sudo "$EDITOR" /etc/default/grub
```

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
