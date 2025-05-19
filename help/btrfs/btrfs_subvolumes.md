# Create separate @ and @home subvolumes post-installation

1. Mount the top-level subvolume (5)
    - sudo mount -o subvolid=5 /dev/root-partition /mnt  
2. Create the subvolumes
    - sudo btrfs subvolume create /mnt/@ 
        - for Debian, rename @rootfs to @
            - sudo mv /mnt/@rootfs /mnt/@
    - sudo btrfs subvolume create /mnt/@home  
3. Edit /etc/fstab to reflect the changes:
    - UUID=x   /     btrfs  defaults,subvol=/@ 0 0
    - UUID=x  /home  btrfs  defaults,subvol=/@home 0 0
4. Remount the filesystems
    - systemctl daemon-reload  
    - sudo mount -a  
