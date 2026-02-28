# nvidia-nano-bujosa

Configuration, scripts, and documentation for a **NVIDIA Jetson Orin Nano Super** device.

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
nvidia-nano-bujosa/
├── comfyui/           # ComfyUI setup, config, and model management
├── monitoring/        # Resource monitoring and optimization scripts
└── README.md
```

## Quick Access

```bash
# SSH into the device
ssh nano

# Check status
ssh nano 'free -h && sudo docker stats --no-stream'
```

## Power Consumption (24/7)

| Mode | Watts | Monthly (~$0.15/kWh) |
|------|-------|----------------------|
| Idle | ~7W | ~$0.77 |
| Moderate | ~15W | ~$1.64 |
| Full GPU | ~25W | ~$2.74 |
