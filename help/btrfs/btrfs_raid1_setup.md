# RAID1 Setup

1. Install the "btrfs-progs" package
2. Create the btrfs file system with RAID
    - sudo mkfs.btrfs -m raid1 -d raid1 /dev/drive1 /dev/drive2
3. Make mount directory
    - sudo mkdir -pv /mnt/raid1
4. Mount the file system
    - sudo mount -o device=/dev/drive1,device=/dev/drive2 /dev/drive1 /mnt/raid1
5. Verify the RAID configuration
    - sudo btrfs flesystem df /mnt/raid1
6. Add more devices (optional)
    - sudo btrfs device add /dev/drive3 /mnt/raid1
    - sudo btrfs balance start /mnt/raid1
7. Add entry to /etc/fstab
    - sudo nano /etc/fstab
    - /dev/drive1 /mnt/raid1 btrfs compress-force=zstd:1,noatime,nofail 0 0
        - for HDDs, add autodefrag to mount options
