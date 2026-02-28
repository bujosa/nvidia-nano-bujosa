#!/bin/bash
# =============================================================================
# ComfyUI Docker Setup for Jetson Orin Nano Super
# Run this from your local machine (not on the Jetson)
# =============================================================================

set -e

SSH_HOST="nano"          # SSH alias (configure in ~/.ssh/config)
PASS="your_password"     # Jetson sudo password

GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[ok]${NC} $1"; }

# Pull ComfyUI Docker image
echo "Pulling ComfyUI Docker image (~5.9GB)..."
ssh "$SSH_HOST" "echo '$PASS' | sudo -S docker pull dustynv/comfyui:r36.4.3"
log "Image pulled"

# Run container
ssh "$SSH_HOST" "
    echo '$PASS' | sudo -S docker run -d \
        --name comfyui \
        --runtime nvidia \
        --restart always \
        --network=host \
        dustynv/comfyui:r36.4.3
"
log "Container started"

# Download models
echo "Downloading Stable Diffusion 1.5 (4GB)..."
ssh "$SSH_HOST" "
    echo '$PASS' | sudo -S docker exec comfyui wget -q --show-progress \
        -O /opt/ComfyUI/models/checkpoints/sd-v1-5.safetensors \
        'https://huggingface.co/stable-diffusion-v1-5/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors'
"
log "SD 1.5 downloaded"

echo "Downloading Realistic Vision v5.1 (2GB)..."
ssh "$SSH_HOST" "
    echo '$PASS' | sudo -S docker exec comfyui wget -q --show-progress \
        -O /opt/ComfyUI/models/checkpoints/realistic-vision-v51.safetensors \
        'https://huggingface.co/SG161222/Realistic_Vision_V5.1_noVAE/resolve/main/Realistic_Vision_V5.1_fp16-no-ema.safetensors'
"
log "Realistic Vision v5.1 downloaded"

# Restart to detect models
ssh "$SSH_HOST" "echo '$PASS' | sudo -S docker restart comfyui"

echo ""
log "ComfyUI ready at http://<JETSON_IP>:8188"
