# Create Subvolumes Post-Installation
1. Mount the top-level subvolume
    
    ```bash
    sudo mount -o subvolid=5 /dev/sdX /mnt
    ```
    
2. Identify existing subvolumes

    ```bash
    sudo btrfs subvolume list /mnt
    ```
    
3. Create or rename subvolume for `/` (root)
    - If `@` already exists, skip

## Debian default
    
```bash
sudo mv /mnt/@rootfs /mnt/@
```
    
## Fedora default
    
```bash
sudo mv /mnt/root /mnt/@
```

## Other

```bash
sudo btrfs subvolume create /mnt/@
```
    
4. Create or rename subvolume for `/home`
    - If `@home` already exists, skip
    - Check if subvolume or directory
    
        ```bash
        sudo btrfs subvolume show /mnt/home 2>/dev/null && echo "subvolume" || echo "directory"
        ```
    
## If `/mnt/home` is a subvolume (common on Fedora default installs)
    
```bash
sudo mv /mnt/home /mnt/@home
```

## If `/mnt/home` is a directory

```bash
sudo btrfs subvolume create /mnt/@home
sudo rsync -aHAXPvh /mnt/home/ /mnt/@home/
sudo rm -rf /mnt/home/*
```

5. Create additional subvolumes for `/var/lib/flatpak` and `/var/lib/libvert/images`
    - If they already exist, skip
    
```bash
sudo btrfs subvolume create /mnt/@flatpak
sudo btrfs subvolume create /mnt/@libvert-images
```

6. Confirm the UUID, then edit /etc/fstab

    ```bash
    sudo blkid -o list
    sudo "$EDITOR" /etc/fstab
    ```
    
    ```
    UUID=x /                        btrfs compress=zstd:1,noatime,subvol=@                  0 0
    UUID=x /var/lib/flatpak         btrfs compress=zstd:1,noatime,subvol=@flatpak           0 0
    UUID=x /var/lib/libvert/images  btrfs compress=zstd:1,noatime,subvol=@libvert-images    0 0
    UUID=x /home                    btrfs compress=zstd:1,noatime,subvol=@home              0 0
    ```

7. Remount

    ```bash
    systemctl daemon-reload  
    sudo mount -a  
    ```

8. Update GRUB, then reboot
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
