# Getting Started with Jetson Orin Nano Super

Complete guide to set up your NVIDIA Jetson Orin Nano Super from scratch for AI workloads.

## Prerequisites

- NVIDIA Jetson Orin Nano Super Developer Kit
- MicroSD card (64GB+ recommended) or NVMe SSD
- USB-C power supply (included)
- Ethernet cable or WiFi connection
- Another computer (Mac/Linux/Windows) for SSH access

## Step 1: Flash JetPack 6

1. Download the SD card image from [NVIDIA JetPack SDK](https://developer.nvidia.com/embedded/jetpack-sdk-62)
2. Flash with [Balena Etcher](https://etcher.balena.io/)
3. Insert SD card and power on
4. Complete the initial Ubuntu setup (username, password, network)

> **Important:** If your Jetson Orin Nano came with old firmware, you must update it before using JetPack 6.x. Follow the [official firmware update guide](https://developer.nvidia.com/embedded/learn/get-started-jetson-orin-nano-devkit).

## Step 2: Enable SSH

SSH should be enabled by default. Verify:

```bash
sudo systemctl status ssh
# If not running:
sudo systemctl enable --now ssh
```

Find your Jetson's IP:

```bash
hostname -I
```

From your computer, test the connection:

```bash
ssh your_user@<JETSON_IP>
```

## Step 3: Set Up Passwordless SSH

On your local machine:

```bash
# Generate key if you don't have one
ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519

# Copy to Jetson
ssh-copy-id -i ~/.ssh/id_ed25519.pub your_user@<JETSON_IP>

# Add alias to ~/.ssh/config
cat >> ~/.ssh/config <<EOF
Host nano
    HostName <JETSON_IP>
    User your_user
    IdentityFile ~/.ssh/id_ed25519
EOF
```

Now connect with just: `ssh nano`

## Step 4: Disable GUI (Headless Mode)

Disabling the desktop environment frees ~500MB-1GB RAM for AI workloads.

```bash
# Disable GUI (takes effect after reboot)
sudo systemctl set-default multi-user.target

# Stop GUI immediately without reboot
sudo systemctl stop gdm3

# To re-enable GUI later
sudo systemctl set-default graphical.target
```

> **Important:** Set up SSH access BEFORE disabling GUI so you don't get locked out.

## Step 5: Set Static IP

```bash
# List your network connections
nmcli con show

# Set static IP (edit values for your network)
sudo nmcli con mod "your_wifi" \
    ipv4.method manual \
    ipv4.addresses 192.168.1.50/24 \
    ipv4.gateway 192.168.1.1 \
    ipv4.dns "8.8.8.8,8.8.4.4"

# Optional: disable IPv6
sudo nmcli con mod "your_wifi" ipv6.method disabled

# Apply changes
sudo nmcli con down "your_wifi" && sudo nmcli con up "your_wifi"
```

## Step 6: Disable Sleep/Suspend

Essential for 24/7 operation:

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

## Step 7: Set Max Performance Mode

```bash
# Check available power modes
sudo nvpmodel -q

# Set to MAXN (max performance) - mode 0
sudo nvpmodel -m 0

# Or MAXN_SUPER (uncapped, highest performance) - mode 2
sudo nvpmodel -m 2

# Lock clocks to maximum
sudo jetson_clocks
```

### Power Modes Reference

| Mode | Name | Power | Use Case |
|------|------|-------|----------|
| 0 | MAXN | 15W | Max performance with power limit |
| 1 | 25W | 25W | High performance |
| 2 | MAXN_SUPER | Uncapped | Maximum possible performance |

## Step 8: Optimize Memory

### Increase Swap (if needed)

```bash
# Check current swap
free -h

# Create 8GB swap file
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
```

### Clear Cache (free RAM)

```bash
sudo sh -c "sync && echo 3 > /proc/sys/vm/drop_caches"
```

### Disable Unnecessary Services

```bash
# Stop and disable services you don't need
sudo systemctl disable --now snapd
sudo systemctl disable --now cups          # Printing
sudo systemctl disable --now bluetooth
sudo systemctl disable --now ModemManager
sudo systemctl disable --now avahi-daemon
```

## Step 9: Install Docker (if not present)

Docker comes pre-installed with JetPack. Verify:

```bash
docker --version
sudo docker run --rm --runtime nvidia hello-world
```

Add your user to the docker group (avoids `sudo`):

```bash
sudo usermod -aG docker $USER
# Log out and back in for this to take effect
```

## Step 10: Verify GPU Access

```bash
# Check CUDA
nvcc --version

# Check GPU with Python
python3 -c "import subprocess; print(subprocess.check_output(['nvidia-smi']).decode())" 2>/dev/null || \
    echo "Use tegrastats for Jetson GPU monitoring"

# Real-time monitoring
sudo tegrastats
```

## Monitoring Commands

```bash
# Full system status
free -h                          # RAM usage
sudo tegrastats                  # GPU/CPU/temp real-time
sudo nvpmodel -q                 # Current power mode
df -h /                          # Disk usage
uptime                           # System uptime
sudo docker stats --no-stream    # Container resource usage
```

## What's Included in JetPack 6

| Component | Version |
|-----------|---------|
| CUDA | 12.6 |
| cuDNN | 9.3 |
| TensorRT | 10.3 |
| VPI | 3.2 |
| OpenCV | 4.8 |
| Ubuntu | 22.04 |
| Kernel | 5.15 |

## Official Resources

- [JetPack SDK Download](https://developer.nvidia.com/embedded/jetpack-sdk-62)
- [Getting Started Guide](https://developer.nvidia.com/embedded/learn/get-started-jetson-orin-nano-devkit)
- [JetPack Install Documentation](https://docs.nvidia.com/jetson/jetpack/install-setup/index.html)
- [Power & Performance Guide](https://docs.nvidia.com/jetson/archives/r35.4.1/DeveloperGuide/text/SD/PlatformPowerAndPerformance/JetsonOrinNanoSeriesJetsonOrinNxSeriesAndJetsonAgxOrinSeries.html)
- [NVIDIA Developer Forums](https://forums.developer.nvidia.com/c/agx-autonomous-machines/jetson-embedded-systems/jetson-orin-nano/)
- [Jetson Containers (pre-built AI Docker images)](https://github.com/dusty-nv/jetson-containers)

## Next Steps

- Set up [ComfyUI](../comfyui/) for AI image generation
- Check [monitoring scripts](../monitoring/) for resource management
