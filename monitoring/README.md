# Monitoring & Optimization

Scripts and commands for monitoring resources and optimizing performance on the Jetson Orin Nano Super.

## Quick Status

```bash
# One-liner full status
ssh nano 'bash -s' < status.sh
```

## Scripts

| Script | Description |
|--------|-------------|
| `status.sh` | Full system status (RAM, GPU, CPU, temp, docker, processes) |
| `optimize.sh` | Free RAM and optimize for AI workloads |
| `tegrastats-monitor.sh` | Real-time GPU/CPU/temp monitoring |

## Key Metrics

- **RAM**: 8GB shared between CPU and GPU. ComfyUI needs ~3-4.5GB
- **GPU**: 1024-core Ampere, monitor with `tegrastats`
- **Temperature**: Safe up to ~80°C, throttles at 85°C
- **Power**: 7-25W depending on load
