# Compression Algorithms
- **zstd on modern systems**
    - higher compression ratio, higher CPU cost
- **lz4 on weak systems**
    - lower compression ratio, lower CPU cost
    
# Universal VM Settings

```
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
vm.max_map_count = 1048576
```

## Explanation
- **vm.watermark_boost_factor = 0**
    - Prevents artificial watermark inflation that would otherwise trigger premature reclaim
- **vm.watermark_scale_factor = 125**
    - Sets watermark hysteresis to a moderate level, avoiding both aggressive reclaim and runaway allocation
- **vm.max_map_count = 1048576**
    - Sets a higher VMA limit to support modern browsers, games, and sandboxed workloads that create large mapping counts

# zram
- compressed swap device in RAM
- best for lower RAM capacity systems (<=32 GiB RAM)
- reclaim cost scales with device size

## Optimal zram config
- **/etc/systemd/zram-generator.conf**

    ```
    zram-size = min(ram, 32768)
    compression-algorithm = zstd
    ```

- **/etc/sysctl.d/99-zram.conf**

    ```
    vm.swappiness = 80
    vm.page-cluster = 0
    vm.compaction_proactiveness = 0
    vm.extfrag_threshold = 1000
    vm.dirty_background_ratio = 10
    vm.dirty_ratio = 20
    ```
    
### Explanation
- **zram-size = min(ram, 32768)**
    - Caps zram at 32 GiB to avoid the steep reclaim‑cost and metadata‑overhead scaling of very large compressed devices
- **compression-algorithm = zstd**
    - Uses zstd because its higher compression ratio reduces memory pressure enough to outweigh its modest CPU cost on modern systems
- **vm.swappiness = 80**
    - Makes reclaim proactive without triggering the pathological anon‑eviction behavior that begins around ~100
- **vm.page-cluster = 0**
    - Sets swap I/O to single‑page operations, minimizing latency and avoiding pointless multi‑page reads on a RAM‑backed device
- **vm.compaction_proactiveness = 0**
    - Disables proactive compaction because zram never requires high‑order allocations and compaction only adds CPU/PSI overhead
- **vm.extfrag_threshold = 1000**
    - Sets the threshold to 1000 to effectively disable compaction entirely, since fragmentation is irrelevant for zram’s order‑0 pages
- **vm.dirty_background_ratio = 10**
    - Keeps the default 10% background writeback trigger, which is already optimal for RAM‑only swap workloads
- **vm.dirty_ratio = 20**
    - Keeps the default 20% cap to prevent excessive dirty‑page buildup without affecting zram behavior


# zswap
- compressed RAM cache in front of physical swap
- best for higher RAM capacity systems (>32 GiB RAM)
- reclaim cost scales with usage, not pool size
- backed by disk, providing a pressure valve

## Optimal zswap config
- **kernel parameters**

    ```
    zswap.enabled=1
    zswap.shrinker_enabled=1
    zswap.max_pool_percent=50
    zswap.compressor=zstd
    zswap.zpool=zsmalloc
    zswap.accept_threshold_percent=90
    ```
    
- **/etc/sysctl.d/99-zswap.conf**

    ```
    vm.swappiness = 40
    vm.page-cluster = 1
    vm.compaction_proactiveness = 10
    vm.extfrag_threshold = 750
    vm.dirty_background_ratio = 5
    vm.dirty_ratio = 10
    ```
    
### Explanation
- **zswap.enabled=1**
    - Enables zswap so anonymous pages are compressed in RAM before hitting physical swap, reducing disk I/O and latency
- **zswap.shrinker_enabled=1**
    - Allows the shrinker to reclaim cold compressed pages, preventing the zswap pool from growing uncontrollably under sustained pressure
- **zswap.max_pool_percent=50**
    - Caps the compressed pool at 50% of RAM to avoid runaway memory consumption while still providing a large, effective compression cache
- **zswap.compressor=zstd**
    - Uses zstd because its higher compression ratio reduces memory pressure enough to outweigh its modest CPU cost on modern systems
- **zswap.zpool=zsmalloc**
    - Selects zsmalloc because it is optimized for small, variable‑sized compressed objects and minimizes fragmentation
- **zswap.accept_threshold_percent=90**
    - Accepts pages into zswap until 90% of the pool is full, maximizing compression benefits before falling back to disk swap
- **vm.swappiness = 40**
    - Sets swappiness to 40 so zswap acts as a compression cache rather than aggressively evicting warm anonymous pages
- **vm.page-cluster = 1**
    - Uses small multi‑page reads that balance latency with throughput on a compressed‑RAM backend
- **vm.compaction_proactiveness = 10**
    - Keeps proactive compaction modest so THP and high‑order allocations remain reliable without causing unnecessary CPU/PSI churn
- **vm.extfrag_threshold = 750**
    - Sets a moderate fragmentation threshold so compaction only activates when high‑order allocations genuinely need it
- **vm.dirty_background_ratio = 5**
    - Sets the background writeback trigger to 5% to reduce dirty‑page buildup and keep reclaim smooth under zswap‑heavy workloads
- **vm.dirty_ratio = 10**
    - Sets the dirty‑page cap to 10% to prevent sudden writeback spikes that can interact poorly with memory pressure

