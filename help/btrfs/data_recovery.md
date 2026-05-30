# Recover Data from a Read-Only BTRFS Drive
1. Create a bootable USB drive

2. Boot into a live session with the bootable USB drive

3. Mount the Btrfs filesystem read-only

    ```bash
    sudo mount -o ro /dev/sdX /mnt
    ```

4. Rsync the data to the target drive

    ```bash
    rsync -aHAXPvh /mnt/ /path/to/drive/
    ```

5. Unmount

    ```bash
    sudo umount /mnt
    ```
