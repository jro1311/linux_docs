# Partition Sizes
## EFI Partition
- **Grub**
    - fat32
    - `/boot/efi` 
        - 128 MiB minimum
        - 512 MiB recommended
- **Systemd-boot**
    - fat32
    - `/boot/efi` 
        - 512 MiB minimum
        - 1 GiB recommended
        
## File System Options
- **btrfs**
    - full‑featured copy‑on‑write filesystem with snapshots and compression
- **ext4**
    - extremely stable, low‑overhead journaling filesystem
- **xfs**
    - high‑performance journaling filesystem, ideal for large files and large disks
    
## / Partition (Default Layout)
- Use a full‑size `/` partition when you do not want a separate `/home` partition

## Separate / and /home Partitions (Optional)
- **<=64 GiB disk** 
    - do not use a separate `/home` partition
    - use a full size `/` partition
- **128 GiB disk**
    - `/` = 40 GiB
    - `/home` = rest
- **256 GiB disk**
    - `/` = 60 GiB
    - `/home` = rest
- **512 GiB disk**
    - `/` = 80 GiB
    - `/home` = rest
- **>=1 TiB disk**
    - `/` = 100 GiB
    - `/home` = rest
