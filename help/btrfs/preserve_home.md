# Preserve Home Subvolume Through Installs
1. Boot into a live session from a USB drive

2. Mount the btrfs partition at the top-level

    ```bash
    sudo mkdir -p /mnt
    sudo mount -o subvolid=5 /dev/sdX /mnt
    ```

3. Delete and recreate the root subvolume

    ```bash
    sudo btrfs subvolume delete /mnt/@
    sudo btrfs subvolume create /mnt/@
    ```

4. Unmount

    ```bash
    sudo umount /mnt
    ```

5. Begin installation

6. In manual/custom partitioning
    - Select the existing btrfs partition
    - DO NOT format
    - Assign mount points
        - `/` to `@`
        - `/home` to `@home`
    - If the installer tries to create new subvolumes, disable that option
    
7. Use the same username as before

8. Complete installation
