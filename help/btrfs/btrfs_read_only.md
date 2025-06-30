# Recover data from a read-only btrfs drive

1. Create a live USB
2. Boot from the live USB
3. Mount the btrfs filesystem
    - sudo mount -o ro /dev/sdX /mnt
4. Rsync the read-only drive with the target drive
    - rsync -av /mnt/ /mnt2/
5. Unmount the drives
    - sudo umount /mnt
    - sudo umount /mnt2
