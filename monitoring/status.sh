#!/bin/bash
# =============================================================================
# Jetson Orin Nano Super - Full System Status
# Usage: ssh nano 'bash -s' < status.sh
# =============================================================================

echo "========================================="
echo " NVIDIA Jetson Orin Nano Super - Status"
echo " $(date)"
echo "========================================="

echo ""
echo "--- RAM ---"
free -h | grep -E "total|Mem|Swap"

echo ""
echo "--- GPU/CPU/TEMP (tegrastats snapshot) ---"
sudo tegrastats --interval 1000 2>/dev/null | head -1 || echo "tegrastats not available"

echo ""
echo "--- Docker Containers ---"
sudo docker stats --no-stream 2>/dev/null || echo "Docker not running"

echo ""
echo "--- Top Processes by Memory ---"
ps aux --sort=-%mem | head -8

echo ""
echo "--- Disk Usage ---"
df -h / | tail -1

echo ""
echo "--- Network ---"
echo "IP: $(hostname -I | awk '{print $1}')"
echo "DNS: $(resolvectl status 2>/dev/null | grep 'Current DNS' | head -1 || nmcli dev show 2>/dev/null | grep DNS | head -1)"

echo ""
echo "--- Services ---"
echo "ComfyUI: $(sudo docker inspect -f '{{.State.Status}}' comfyui 2>/dev/null || echo 'not found')"
echo "Ollama:  $(systemctl is-active ollama 2>/dev/null || echo 'not found')"
echo "Docker:  $(systemctl is-active docker 2>/dev/null || echo 'not found')"

echo ""
echo "--- Uptime ---"
uptime
