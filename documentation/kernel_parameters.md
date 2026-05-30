# Kernel Parameters
## Preemption Modes
- preempt=`[none|voluntary|lazy|full]`

## AMD GPU Power Management
- amdgpu.ppfeaturemask=0xffffffff

## zswap Configuration
- zswap.enabled=`[0|1]`
- zswap.shrinker_enabled=`[0|1]`
- zswap.max_pool_percent=`[0-100]`
- zswap.compressor=`[lz4|zstd]`
- zswap.zpool=`[zsmalloc]`
- zswap.accept_threshold_percent=`[0-100]`
