# Partition Sizes

# EFI

- **Grub**
    - 128 MiB minimum, 512 MiB recommended
- **Systemd-boot**
    - 512 MiB minimum, 1 GiB recommended

# / and /home

- **Any**
    - full size / btrfs partition
- **<=120 GB**
    - full size / btrfs partition
- **250 GiB**
    - 60 GiB / btrfs partition
    - rest /home ext4 partition
- **500 GiB**
    - 80 GiB / btrfs partition
    - rest /home ext4 partition
- **1 TiB**
    - 100 GiB / btrfs partition
    - rest /home ext4 partition
- **2 TiB**
    - 120 GiB / btrfs partition
    - rest /home ext4 partition
- **4 TiB**
    - 140 GiB / btrfs partition
    - rest /home ext4 partition
