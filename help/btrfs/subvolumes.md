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
sudo rsync -aHAXP /mnt/home/ /mnt/@home/
sudo rm -rf /mnt/home/*
```

5. Create additional subvolumes for `/var/lib/flatpak`, `/var/lib/libvert/images`, and `/var/cache`
    - If they already exist, skip
    
```bash
sudo btrfs subvolume create /mnt/@flatpak
sudo btrfs subvolume create /mnt/@libvert-images
sudo btrfs subvolume create /mnt/@cache
```

6. Migrate essential directories, remove old data, and fix permissions and labels

```bash
# Migrate only if:
# 1. The old directory exists
# 2. The old directory is non-empty
# 3. The @flatpak subvolume is mounted at /var/lib/flatpak
set -- /mnt/@/var/lib/flatpak/*
if [ -d /mnt/@/var/lib/flatpak ] \
    && [ -e "$1" ] \
    && findmnt -no OPTIONS /var/lib/flatpak | grep -Fq "subvol=/@flatpak"; then

    sudo rsync -aHAXP /mnt/@/var/lib/flatpak/ /mnt/var/lib/flatpak/
    sudo rm -rf /mnt/@/var/lib/flatpak
    sudo mkdir -p /mnt/@/var/lib/flatpak
    sudo chown -R root:root /var/lib/flatpak

    flatpak repair || :
fi

sudo rsync -aHAXP /mnt/@/var/lib/libvirt/images/ /mnt/@libvirt-images/
sudo rm -rf /mnt/@/var/lib/libvirt/images
sudo rm -rf /mnt/@/var/cache
sudo mkdir -p /mnt/@/var/lib/libvirt/images
sudo mkdir -p /mnt/@/var/cache

if command -v restorecon >/dev/null 2>&1; then
    paths=(
        /var/lib/flatpak
        /var/lib/libvirt
        /var/lib/libvirt/images
        /var/cache
    )

    for path in "${paths[@]}"; do
        sudo restorecon -RF "$path" || :
    done
fi
```

7. Confirm UUIDs, then edit /etc/fstab

    ```bash
    sudo blkid -o list
    sudo "$EDITOR" /etc/fstab
    ```
    
    ```
    UUID=x /                        btrfs noatime,compress=zstd:1,subvol=@                  0 0
    UUID=x /home                    btrfs noatime,compress=zstd:1,subvol=@home              0 0
    UUID=x /var/lib/flatpak         btrfs noatime,compress=zstd:1,subvol=@flatpak           0 0
    UUID=x /var/lib/libvert/images  btrfs noatime,compress=zstd:1,subvol=@libvert-images    0 0
    UUID=x /var/cache               btrfs noatime,compress=zstd:1,subvol=@cache             0 0
    ```

8. Unmount, then remount

    ```bash
    sudo umount /mnt
    systemctl daemon-reload  
    sudo mount -a  
    ```

9. Verify changes, and make adjustments if necessary

    ```bash
    sudo findmnt --verify --verbose
    ```

10. Update GRUB (or whichever bootloader you use), then reboot
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
