# Partition Sizes

# EFI

- **Grub**
    - 128 MiB minimum, 512 MiB recommended (fat32)
- **Systemd-boot**
    - 512 MiB minimum, 1 GiB recommended (fat32)

# / and /home

- **Any**
    - full size / partition (btrfs or ext4)
- **<=64 GiB**
    - full size / partition (btrfs or ext4)
- **128 GiB**
    - 40 GiB / partition (btrfs or ext4)
    - rest /home partition (ext4)
- **256 GiB**
    - 60 GiB / partition (btrfs or ext4)
    - rest /home partition (ext4)
- **512 GiB**
    - 80 GiB / partition (btrfs or ext4)
    - rest /home partition (ext4)
- **>=1 TiB**
    - 100 GiB / partition (btrfs or ext4)
    - rest /home partition (ext4)
