# zRAM Generator

## Compression Algorithm

- **zstd**
    - slower, better compression ratios (3-4:1)
- **lz4** 
    - faster, worse compression ratios (2-3:1)

## /etc/systemd/zram-generator.conf

```
[zram0]
zram-size = ram
compression-algorithm = zstd
```

## /etc/sysctl.d/99-zram.conf

```
vm.swappiness = 180
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
vm.page-cluster = 0
vm.max_map_count = 1048576
```

- **Check** 

```bash
zramctl
```

- **Edit**  

```bash
sudo nano /etc/systemd/zram-generator.conf
```

``` bash
sudo nano /etc/sysctl.d/99-zram.conf
```
    
- If there is a zram-generator.conf file in both /etc/systemd/ and /usr/lib/systemd/, the version in /etc/systemd/ will take precedence
    
# Remove Existing Swapfile

```bash
sudo swapoff /swapfile
sudo rm -v /swapfile
sudo sed -i '/\/swapfile/d' /etc/fstab
```
