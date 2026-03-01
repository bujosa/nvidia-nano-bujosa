# Performance Tuning Guide

Optimize your Jetson Orin Nano Super for maximum AI performance.

## 1. Disable GUI (Save ~500MB-1GB RAM)

The desktop environment uses significant RAM. For headless AI workloads, disable it:

```bash
# Disable GUI on next boot
sudo systemctl set-default multi-user.target

# Stop GUI immediately
sudo systemctl stop gdm3

# Verify (should show "multi-user.target")
systemctl get-default
```

To re-enable:
```bash
sudo systemctl set-default graphical.target
sudo reboot
```

## 2. Power Mode Configuration

### Available Power Modes

| Mode | Name | Power | CPU Cores | CPU Max Freq | GPU Max Freq |
|------|------|-------|-----------|-------------|-------------|
| 0 | MAXN | 15W | 6 | 1.5 GHz | 1.02 GHz |
| 1 | 25W | 25W | 6 | 1.5 GHz | 1.02 GHz |
| 2 | MAXN_SUPER | Uncapped | 6 | 1.7 GHz | 1.10 GHz |

### Set Power Mode

```bash
# Check current mode
sudo nvpmodel -q

# Set MAXN_SUPER (highest performance)
sudo nvpmodel -m 2

# Lock all clocks to maximum
sudo jetson_clocks

# Verify
sudo jetson_clocks --show
```

> Power mode persists across reboots. `jetson_clocks` does NOT persist — add it to a startup script if needed.

### Make jetson_clocks Persist

```bash
# Create systemd service
sudo tee /etc/systemd/system/jetson-clocks.service <<EOF
[Unit]
Description=Set Jetson clocks to maximum
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/jetson_clocks

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable jetson-clocks
```

## 3. Memory Optimization

### RAM Overview

The Jetson Orin Nano Super has **8GB LPDDR5 shared** between CPU and GPU. Every MB counts.

### Clear Filesystem Cache

```bash
sudo sh -c "sync && echo 3 > /proc/sys/vm/drop_caches"
```

### Disable Unnecessary Services

```bash
# Check what's using memory
ps aux --sort=-%mem | head -15

# Common services to disable for AI workloads
sudo systemctl disable --now snapd            # Snap package manager
sudo systemctl disable --now cups             # Printing
sudo systemctl disable --now cups-browsed
sudo systemctl disable --now bluetooth
sudo systemctl disable --now ModemManager
sudo systemctl disable --now avahi-daemon     # mDNS
sudo systemctl disable --now whoopsie         # Error reporting
sudo systemctl disable --now kerneloops
sudo systemctl disable --now packagekitd
```

### Swap Configuration

Swap lets you use NVMe storage as extra RAM (slower but prevents OOM crashes):

```bash
# Check current swap
free -h

# If you need more swap
sudo swapoff -a
sudo fallocate -l 12G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab

# Reduce swappiness (prefer RAM, use swap only when needed)
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## 4. GPU Optimization

### Set GPU to Performance Governor

```bash
# Check current governor
cat /sys/devices/gpu.0/devfreq/*/governor

# Set to performance (always max frequency)
echo "performance" | sudo tee /sys/devices/gpu.0/devfreq/*/governor
```

### Monitor GPU Usage

```bash
# Real-time monitoring
sudo tegrastats --interval 1000

# Key metrics:
# GR3D_FREQ = GPU usage percentage
# RAM = Memory usage
# VDD_IN = Total power consumption
# gpu@ = GPU temperature
```

## 5. Docker Optimization

### Use NVIDIA Runtime

Always use `--runtime nvidia` for GPU access:

```bash
sudo docker run --runtime nvidia ...
```

### Set as Default Runtime

```bash
sudo tee /etc/docker/daemon.json <<EOF
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
EOF

sudo systemctl restart docker
```

### Limit Container Memory

Prevent containers from using all RAM:

```bash
# Limit container to 6GB
sudo docker run --runtime nvidia --memory=6g ...
```

## 6. Thermal Management

### Monitor Temperature

```bash
# Quick check
cat /sys/devices/virtual/thermal/thermal_zone*/temp

# With tegrastats (shows gpu@, cpu@, soc@ temps)
sudo tegrastats --interval 2000
```

### Temperature Thresholds

| Zone | Normal | Warning | Throttle |
|------|--------|---------|----------|
| CPU | < 70°C | 70-80°C | > 85°C |
| GPU | < 70°C | 70-80°C | > 85°C |

If throttling occurs, consider adding a fan or heatsink.

## 7. Quick Optimization Script

Run this before AI workloads:

```bash
#!/bin/bash
# optimize-for-ai.sh

# Set max performance
sudo nvpmodel -m 2
sudo jetson_clocks

# Clear cache
sudo sh -c "sync && echo 3 > /proc/sys/vm/drop_caches"

# Stop unnecessary services
for svc in snapd cups bluetooth ModemManager avahi-daemon whoopsie; do
    sudo systemctl stop "$svc" 2>/dev/null
done

# GPU performance mode
echo "performance" | sudo tee /sys/devices/gpu.0/devfreq/*/governor > /dev/null

echo "Optimized for AI workloads"
free -h | grep Mem
```

## RAM Usage Reference

| Component | Approximate RAM Usage |
|-----------|-----------------------|
| Base system (headless) | ~800MB |
| Desktop GUI (GNOME) | ~500MB-1GB |
| Docker daemon | ~50MB |
| ComfyUI (idle) | ~500MB |
| ComfyUI + SD 1.5 loaded | ~3-4GB |
| ComfyUI + SD 1.5 generating | ~5-6GB |
| Ollama (idle) | ~20MB |
| Ollama + 7B model loaded | ~4-5GB |
