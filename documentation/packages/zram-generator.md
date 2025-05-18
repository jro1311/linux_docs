# Remove existing swapfile
sudo swapoff /swapfile
sudo rm -v /swapfile
sudo sed -i '/\/swapfile/d' /etc/fstab

# /etc/systemd/zram-generator.conf
[zram0]
zram-size = min(ram, 8192)
compression-algorithm = zstd

# /etc/sysctl.d/99-zram.conf
vm.swappiness = 180
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
vm.page-cluster = 0
vm.max_map_count = 1048576

# Notes
- Use zramctl or swapon to confirm that the device has been created and is in use
- Edit in /etc/systemd/zram-generator.conf or /usr/lib/systemd/zram-generator.conf or /etc/sysctl.d/99-zram.conf
    - If you have a zram-generator.conf file in both /etc/systemd/ and /usr/lib/systemd/, the version in /etc/systemd/ will take precedence

## Compression Algorithm
- zstd - slower, better compression ratios (3-4:1)
- lz4 - faster, worse compression ratios (2-3:1)
