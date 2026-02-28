# ComfyUI Setup

ComfyUI running on Docker with NVIDIA GPU acceleration for AI image generation.

## Access

```
http://<JETSON_IP>:8188
```

## Docker Container

```bash
# Container: dustynv/comfyui:r36.4.3
# Runtime: nvidia
# Restart: always (survives reboots)
# Network: host (port 8188)
```

## Models

| Model | File | Size | Use Case |
|-------|------|------|----------|
| Stable Diffusion 1.5 | `sd-v1-5.safetensors` | 4 GB | General purpose, art, styles |
| Realistic Vision v5.1 | `realistic-vision-v51.safetensors` | 2 GB | Photorealistic portraits |

Models are stored in: `/opt/ComfyUI/models/checkpoints/` (inside container)

Generated images are saved in: `/opt/ComfyUI/output/` (inside container)

## Commands

```bash
# View logs
ssh nano 'sudo docker logs --tail 20 comfyui'

# Restart ComfyUI
ssh nano 'sudo docker restart comfyui'

# List generated images
ssh nano 'sudo docker exec comfyui ls -lh /opt/ComfyUI/output/'

# Delete all generated images
ssh nano 'sudo docker exec comfyui sh -c "rm -f /opt/ComfyUI/output/ComfyUI_*.png"'

# Download a new model
ssh nano 'sudo docker exec comfyui wget -O /opt/ComfyUI/models/checkpoints/MODEL_NAME.safetensors "URL"'
```

## Recommended Settings for 8GB RAM

| Setting | Value |
|---------|-------|
| Resolution | 384x512 or 512x512 |
| Steps | 15-20 |
| Sampler | euler |
| Scheduler | normal |
| CFG | 7-8 |
| Batch size | 1 |

## Tips

- Use **fp16** models (half memory usage)
- Clear system cache before generating if low on RAM
- The first image after loading a model takes longer (model loading)
- Use negative prompts like `blurry, deformed, ugly, cartoon` for better results
