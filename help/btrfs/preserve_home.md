# Preserve Home Subvolume Through Installs

1. Boot into a live session from a USB drive
2. Mount the partition containing your existing installation to a temporary mount point

    ```bash
    sudo mkdir -p /mnt
    sudo mount -o /dev/sdX /mnt
    ```

3. Delete everything inside the root subvolume of the mounted partition

    ```bash
    sudo rm -rf /mnt/@/*
    ```

4. Unmount the temporary mount point

    ```bash
    sudo umount /mnt
    ```

5. Start the installer for your chosen distribution

6. On the "Installation type" or "Partitioning" window, choose the option for a custom or manual installation

7. On the partitioning window, select the partition containing your existing installation
    - Specify the mount point as the root directory (/)
    - DO NOT format the partition
    
8. On the "user setup" or "create user" window, use the same username as in the previous installation

9. Finish the installation process
