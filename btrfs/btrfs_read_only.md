# Recover data from a read-only btrfs drive
1. Create a live USB
2. Boot from the live USB
3. Mount the Btrfs filesystem
    - sudo mount -o ro /dev/sdX /mnt
4. Transfer the files
    - sudo rsync -av /mnt/ /mnt2/
5. Unmount the drives
    - sudo umount /mnt
    - sudo umount /mnt2
