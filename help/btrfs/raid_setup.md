# RAID1 Setup
1. Install package `btrfs-progs`
2. Create the RAID1 filesystem

    ```bash
    sudo mkfs.btrfs -m raid1 -d raid1 /dev/drive1 /dev/drive2
    ```

3. Make mount directory

    ```bash
    sudo mkdir -p /mnt/raid1
    ```

4. Mount the filesystem
    - btrfs automatically assembles all RAID1 devices when mounting any one of them

    ```bash
    sudo mount /dev/drive1 /mnt/raid1
    ```

5. Verify the RAID configuration

    ```bash
    sudo btrfs filesystem df /mnt/raid1
    ```

6. Add more devices (optional)

    ```bash
    sudo btrfs device add /dev/drive3 /mnt/raid1
    sudo btrfs balance start /mnt/raid1
    ```
    
7. Confirm the UUID, then edit /etc/fstab

    ```bash
    sudo blkid -o list
    sudo "$EDITOR" /etc/fstab
    ```
    
    ```
    UUID=<uuid> /mnt/raid1 btrfs compress=zstd:1,noatime,nofail 0 0
    ```
