# Compression Algorithms

- **zstd on modern systems**
    - higher compression ratio, higher CPU cost
- **lz4 on weak systems**
    - lower compression ratio, lower CPU cost

# zram

- compressed swap device in RAM
- best for lower RAM capacity systems (<=32 GiB RAM)
- reclaim cost scales with device size
- **optimal zram config**
    ```
    zram-size = min(ram, 32768)
    compression-algorithm = zstd
    ```

# zswap

- compressed RAM cache in front of physical swap
- best for higher RAM capacity systems (>32 GiB RAM)
- reclaim cost scales with usage, not pool size
- backed by disk, providing a pressure valve
- **optimal zswap config**
    ```
    zswap.enabled=1
    zswap.shrinker_enabled=1
    zswap.max_pool_percent=50
    zswap.compressor=zstd
    zswap.zpool=zsmalloc
    zswap.accept_threshold_percent=90
    ```
