# Recover Data from a Read-Only BTRFS Drive

1. Create a bootable USB drive
2. Boot into a live session with the bootable USB drive
3. Mount the btrfs filesystem

    ```bash
    sudo mount -o ro /dev/sdX /mnt
    ```

4. Rsync the read-only drive with the target drive

    ```bash
    rsync -av /mnt /path/to/drive
    ```

5. Unmount the drives

    ```bash
    sudo umount /mnt
    ```
