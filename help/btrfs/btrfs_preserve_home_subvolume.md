# Preserve home subvolume through installs

1. Before starting, make an external backup of the important files in your home directory
2. Boot from a live Linux distribution (e.g., from a USB flash drive) and choose the option to try it without installing
3. Mount the partition containing your existing Linux installation (e.g., /dev/sda2) to a temporary mount point (e.g., /mnt/)
4. Delete everything inside the root subvolume of the mounted partition (e.g., /mnt/@/). If you have made a snapshot of the subvolume, you can restore it if needed
5. Unmount the temporary mount point
6. Start the installer for your chosen Linux distribution
7. On the "Installation type" or "Partitioning" window, choose the option for a custom or manual installation
8. On the partitioning window, select the partition containing your existing Linux installation (e.g., /dev/sda2), specify the mount point as the root directory (/), and choose not to format the partition
9. On the "User setup" or "Create user" window, enter a username that matches your previous main username (if desired, to inherit the previous home directory)
10. The installation should proceed normally from this point
