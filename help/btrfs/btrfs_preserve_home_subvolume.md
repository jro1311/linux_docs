# Before starting, make an external backup of the important files in your home directory
1. Boot from a live Linux distribution (e.g., from a USB flash drive) and choose the option to try it without installing
2. Mount the partition containing your existing Linux installation (e.g., /dev/sda2) to a temporary mount point (e.g., /mnt/)
3. Delete everything inside the root subvolume of the mounted partition (e.g., /mnt/@/). If you have made a snapshot of the subvolume, you can restore it if needed
4. Unmount the temporary mount point
5. Start the installer for your chosen Linux distribution
6. On the "Installation type" or "Partitioning" window, choose the option for a custom or manual installation
7. On the partitioning window, select the partition containing your existing Linux installation (e.g., /dev/sda2), specify the mount point as the root directory (/), and choose not to format the partition
8. On the "User setup" or "Create user" window, enter a username that matches your previous main username (if desired, to inherit the previous home directory)
9. The installation should proceed normally from this point
