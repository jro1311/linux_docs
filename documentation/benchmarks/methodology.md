# Methodology
## Test System
- Ryzen 5 5600 (6 cores, 12 threads)
- 16 GiB RAM
- WD SN580 1 TB
- RX 6650 XT (8 GiB VRAM)

## Prime (CPU-X)
- Duration: `1 minute`
- Threads: `12`

## Compression (zstd)
- Slow: `zstd -b`
- Fast: `zstd -b --fast=1`

## KDiskMark
- Tests: `5 * 1 GiB`
- Units: `MB/s`
- NOCOW directory (btrfs)
- Settings
    - `NVME SSD` Preset

## Geeks3D Furmark 
- Benchmark Preset
- Resolution: `2560x1440`
- Settings
    - Anti-Aliasing: `Off`
