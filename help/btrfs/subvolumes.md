# Create Separate @ and @home Subvolumes Post-Installation

1. Mount the top-level subvolume (5)
    
    ```bash
    sudo mount -o subvolid=5 /dev/root-partition /mnt
    ```

2. Create the subvolumes

    ```bash
    sudo btrfs subvolume create /mnt/@
    sudo btrfs subvolume create /mnt/@home  
    ```

- for Debian, rename @rootfs to @

    ```bash
    sudo mv /mnt/@rootfs /mnt/@
    ```

- for Fedora, rename root to @

    ```bash
    sudo mv /mnt/root /mnt/@
    ```

3. Edit /etc/fstab to reflect the changes

    ```bash
    sudo nano /etc/fstab
    ```

    ```
    UUID=x / btrfs compress=zstd:1,noatime,subvol=/@ 0 0
    UUID=x /home btrfs compress=zstd:1,noatime,subvol=/@home 0 0
    ```
 
- for HDDs, add autodefrag to mount options

4. Remount the filesystems

    ```bash
    systemctl daemon-reload  
    sudo mount -a  
    ```

5. Update GRUB

- Conventional

    ```bash
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    ```

- Debian/Debian-based

    ```bash
    sudo update-grub
    ```

- If necessary, edit GRUB entry on boot menu to reflect subvolume changes
