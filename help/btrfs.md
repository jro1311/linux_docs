# BTRFS Guides

## Create Separate @ and @home Subvolumes Post-Installation

1. Mount the top-level subvolume (5)
    
    ```bash
    sudo mount -o subvolid=5 /dev/root-partition /mnt
    ```

2. Create the subvolumes

    ```bash
    sudo btrfs subvolume create /mnt/@
    sudo btrfs subvolume create /mnt/@home  
    ```

- for Debian, rename @rootfs to @

    ```bash
    sudo mv /mnt/@rootfs /mnt/@
    ```

- for Fedora, rename root to @

    ```bash
    sudo mv /mnt/root /mnt/@
    ```

3. Edit /etc/fstab to reflect the changes

    ```bash
    sudo nano /etc/fstab
    ```

    ```
    UUID=x / btrfs compress=zstd:1,noatime,subvol=/@ 0 0
    UUID=x /home btrfs compress=zstd:1,noatime,subvol=/@home 0 0
    ```
 
- for HDDs, add autodefrag to mount options

4. Remount the filesystems

    ```bash
    systemctl daemon-reload  
    sudo mount -a  
    ```

5. Update GRUB

- Conventional

    ```bash
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    ```

- Debian/Debian-based

    ```bash
    sudo update-grub
    ```

- If necessary, edit GRUB entry on boot menu to reflect subvolume changes

## Enable/Disable Copy-On-Write (COW) on Files or Directories

- **Check COW Status**

    ```bash
    lsattr ./file
    lsattr -d dir
    ```

- **Disable COW**

    ```bash
    sudo chattr +C ./file
    ```
    
- Recursively

    ```bash
    sudo chattr -R +C ./directory
    ```
    
- **Enable COW**
    
    ```bash
    sudo chattr -C ./file
    ```
    
- Recursively

    ```bash
    sudo chattr -R -C ./directory
    ```
    
## Maintenance

- **Scrub**
    - https://btrfs.readthedocs.io/en/latest/Scrub.html
    - Verifies checksums of all data and metadata, detects corruption, and repairs it if redundant copies are available
    - Ensures data integrity but does not fix logical metadata inconsistencies
    
- **Balance** 
    - https://btrfs.readthedocs.io/en/latest/btrfs-balance.html
    - Redistributes block groups across devices to improve space usage and prevent allocation problems
    - Useful in multi-device setups, but does not reclaim deleted space or defragment files

## Preserve Home Subvolume Through Installs

1. Boot into a live session from a USB drive
2. Mount the partition containing your existing installation to a temporary mount point

    ```bash
    sudo mkdir -p /mnt
    sudo mount -o /dev/sdX /mnt
    ```

3. Delete everything inside the root subvolume of the mounted partition

    ```bash
    sudo rm -r /mnt/@/*
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

## RAID1 Setup

1. Install the **btrfs-progs** package
2. Create the RAID

    ```bash
    sudo mkfs.btrfs -m raid1 -d raid1 /dev/drive1 /dev/drive2
    ```

3. Make mount directory

    ```bash
    sudo mkdir -p /mnt/raid1
    ```

4. Mount the file system

    ```bash
    sudo mount -o device=/dev/sdX,device=/dev/sdY /dev/sdX /mnt/raid1
    ```

5. Verify the RAID configuration

    ```bash
    sudo btrfs flesystem df /mnt/raid1
    ```

6. Add more devices (optional)

    ```bash
    sudo btrfs device add /dev/sdZ /mnt/raid1
    sudo btrfs balance start /mnt/raid1
    ```

7. Add entry to /etc/fstab

    ```bash
    sudo nano /etc/fstab
    ```

    ```
    /dev/drive1 /mnt/raid1 btrfs compress=zstd:1,noatime,nofail 0 0
    ```

- for HDDs, add autodefrag to mount options

## Recover Data from a Read-Only BTRFS Drive

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

## Subvolume Layout

- **single distro**
    - @ mount to /
    - @home mount to /home
    
- **multi distro**
    - @fedora mount to /
    - @home-fedora mount to /home
    - @flatpak mount to /var/lib/flatpak
