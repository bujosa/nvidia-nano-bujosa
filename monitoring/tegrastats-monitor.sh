#!/bin/bash
# =============================================================================
# Jetson Orin Nano Super - Real-time Monitoring
# Usage: ssh nano 'bash -s' < tegrastats-monitor.sh
# Press Ctrl+C to stop
# =============================================================================

echo "Real-time monitoring (Ctrl+C to stop)"
echo "Format: RAM | CPU | GPU | TEMP | POWER"
echo "========================================="

sudo tegrastats --interval 2000 2>/dev/null | while read -r line; do
    # Extract key metrics
    ram=$(echo "$line" | grep -oP 'RAM \K[^ ]+')
    cpu=$(echo "$line" | grep -oP 'CPU \K\[[^\]]+\]')
    gpu=$(echo "$line" | grep -oP 'GR3D_FREQ \K[^ ]+')
    temp=$(echo "$line" | grep -oP 'gpu@\K[^ ]+')
    power=$(echo "$line" | grep -oP 'VDD_IN \K[^ ]+')

    echo "RAM: $ram | CPU: $cpu | GPU: $gpu | TEMP: $temp | POWER: $power"
done
