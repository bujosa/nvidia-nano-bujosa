#!/bin/bash
# =============================================================================
# Jetson Orin Nano Super - Optimize for AI Workloads
# Usage: ssh nano 'bash -s' < optimize.sh
# =============================================================================

set -e

GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[✓]${NC} $1"; }

echo "========================================="
echo " Optimizing for AI Workloads"
echo "========================================="

echo ""
echo "--- Before ---"
free -h | grep Mem

# 1. Clear filesystem cache
echo ""
sudo sh -c "sync && echo 3 > /proc/sys/vm/drop_caches"
log "Filesystem cache cleared"

# 2. Stop unnecessary services
for svc in ollama snapd cups bluetooth avahi-daemon ModemManager packagekitd; do
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
        sudo systemctl stop "$svc" 2>/dev/null && log "Stopped $svc" || true
    fi
done

# 3. Set GPU to max performance mode
if [ -f /sys/devices/gpu.0/devfreq/17000000.ga10b/governor ]; then
    echo "performance" | sudo tee /sys/devices/gpu.0/devfreq/17000000.ga10b/governor > /dev/null
    log "GPU set to performance mode"
fi

# 4. Set power mode to MAXN (max performance)
if command -v nvpmodel &> /dev/null; then
    sudo nvpmodel -m 0 2>/dev/null && log "Power mode set to MAXN" || true
fi

# 5. Max CPU frequency
if command -v jetson_clocks &> /dev/null; then
    sudo jetson_clocks 2>/dev/null && log "CPU/GPU clocks set to max" || true
fi

echo ""
echo "--- After ---"
free -h | grep Mem

echo ""
log "Optimization complete"
