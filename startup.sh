#!/bin/bash

# Start ComfyUI
cd /home/ComfyUI/ || { echo "Directory ComfyUI not found"; exit 1; }
nohup python main.py --listen 0.0.0.0 > /var/log/comfyui.log 2>&1 &
echo "ComfyUI started on port 8188"

echo "Starting Jupyter Lab on port 8888"
jupyter lab --allow-root --no-browser --ip=0.0.0.0 --port=8888