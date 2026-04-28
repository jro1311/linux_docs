# RAID1 Setup

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
    /dev/drive1 /mnt/raid1 btrfs compress=zstd:1,noatime,nofail 0 0
    ```

- for HDDs, add autodefrag to mount options
