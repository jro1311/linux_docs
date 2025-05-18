# /boot/efi partition sizes based on bootloader
- Grub
    - 128 MiB minimum, 512 MiB recommended
- Systemd-boot
    - 512 MiB minimum, 1 GiB recommended

# Use btrfs with subvolumes on a single partition
- Any
    - full size / btrfs partition

# Use separate / (root) and /home partitions
- <=120 GB
    - full size / btrfs partition

- 250 GiB
    - 60 GiB / btrfs partition
    - rest /home ext4 partition

- 500 GiB
    - 80 GiB / btrfs partition
    - rest /home ext4 partition

- 1 TiB
    - 100 GiB / btrfs partition
    - rest /home ext4 partition

- 2 TiB
    - 120 GiB / btrfs partition
    - rest /home ext4 partition

- 4 TiB
    - 140 GiB / btrfs partition
    - rest /home ext4 partition

- e.g. 1 GiB EFI parititon (/boot/efi), ~500 GiB / btrfs partition with @ and @home subvolumes
- e.g. 1 GiB EFI partition (/boot/efi), 80 GiB / btrfs partition, ~420 GiB /home ext4 partition
