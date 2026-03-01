# nvidia-jetson-nano

Configuration, scripts, and documentation for a **NVIDIA Jetson Orin Nano Super** device running AI workloads 24/7.

## Device Specs

| Component | Spec |
|-----------|------|
| Board | NVIDIA Jetson Orin Nano Super |
| CPU | 6-core ARM Cortex-A78AE (aarch64) |
| RAM | 8 GB LPDDR5 (shared CPU/GPU) |
| GPU | 1024-core NVIDIA Ampere (67 TOPS INT8) |
| CUDA | 12.6 |
| Storage | 229 GB NVMe |
| JetPack | 6.x (R36.4.7) |
| OS | Ubuntu 22.04 (L4T) |

## Structure

```
nvidia-jetson-nano/
├── guides/            # Step-by-step setup and optimization guides
├── comfyui/           # ComfyUI setup, config, and model management
├── monitoring/        # Resource monitoring and optimization scripts
└── README.md
```

## Guides

| Guide | Description |
|-------|-------------|
| [Getting Started](guides/getting-started.md) | Flash JetPack, SSH, static IP, headless mode, performance setup |
| [Performance Tuning](guides/performance-tuning.md) | Power modes, RAM optimization, disable GUI, thermal management |

## Quick Access

```bash
# SSH into the device
ssh nano

# Check status
ssh nano 'free -h && sudo docker stats --no-stream'

# Max performance mode
ssh nano 'sudo nvpmodel -m 2 && sudo jetson_clocks'
```

## Power Consumption (24/7 in USA - Georgia, Atlanta)

Based on Georgia Power residential rate (~$0.15/kWh):

| Mode | Watts | Monthly | Yearly |
|------|-------|---------|--------|
| Idle | ~7W | $0.77 | $9.20 |
| Moderate (AI inference) | ~15W | $1.64 | $19.71 |
| Full GPU load | ~25W | $2.74 | $32.85 |

## Official Resources

- [JetPack SDK](https://developer.nvidia.com/embedded/jetpack-sdk-62)
- [Getting Started Guide](https://developer.nvidia.com/embedded/learn/get-started-jetson-orin-nano-devkit)
- [NVIDIA Developer Forums](https://forums.developer.nvidia.com/c/agx-autonomous-machines/jetson-embedded-systems/jetson-orin-nano/)
- [Jetson Containers](https://github.com/dusty-nv/jetson-containers)
