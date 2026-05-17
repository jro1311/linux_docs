# Kernel Parameters

- **Kernel preemption modes**
    - preempt=`[none|voluntary|lazy|full]`

- **Enable full control of power management on AMD GPUs**
    - amdgpu.ppfeaturemask=0xffffffff
    
- **Configure zswap**
    - zswap.enabled=`[0|1]`
    - zswap.shrinker_enabled=`[0|1]`
    - zswap.max_pool_percent=`[0-100]`
    - zswap.compressor=`[lz4|zstd]`
    - zswap.zpool=`[zsmalloc]`
    - zswap.accept_threshold_percent=`[0-100]`
