# Methodology

## Test Conditions

- Live session on real hardware
- System allowed to settle for 5–10 minutes before recording
- Network disconnected before CPU and RAM usage was recorded
- No applications opened during measurement

## Test System

- Ryzen 5 5600 (6 cores, 12 threads)
- 16 GiB RAM
- RX 6650 XT (8 GiB VRAM)

## Measurement Tools

- CPU tasks measured with `top`
- RAM usage measured with `top`
    - Cached RAM excluded from ranking
- VRAM usage measured with `nvtop`

## Data Normalization

- CPU tasks rounded to the nearest 10
- RAM usage rounded to the nearest 100
- VRAM usage rounded to the nearest 50

## Ranking System

- Lowest value = 0 pts
- Next lowest = +1 pts
- Next = +2 pts
- Continues upward until highest rank
