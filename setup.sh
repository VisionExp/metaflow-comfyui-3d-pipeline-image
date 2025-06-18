#!/bin/bash

cd /home/ComfyUI || { echo "ComfyUI directory not found"; exit 1; }
pip install --cache-dir /root/.cache/pip -r requirements.txt

cd /home/ComfyUI/custom_nodes/ComfyUI-Hunyuan3DWrapper-Linux || { echo "ComfyUI-Hunyuan3DWrapper-Linux directory not found"; exit 1; }
pip install --cache-dir /root/.cache/pip -r requirements.txt

cd /home/ComfyUI/custom_nodes/ComfyUI-Hunyuan3DWrapper-Linux/wheels || { echo "ComfyUI-Hunyuan3DWrapper-Linux/wheels directory not found"; exit 1; }

# shellcheck disable=SC2035
pip install *.whl

repos=(
    "https://github.com/chrisgoringe/cg-use-everywhere.git cg-use-everywhere"
    "https://github.com/giriss/comfy-image-saver.git comfy-image-saver"
    "https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git ComfyUI-Advanced-ControlNet"
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git ComfyUI-Custom-Scripts"
    "https://github.com/kijai/ComfyUI-Florence2.git ComfyUI-Florence2"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack.git ComfyUI-Impact-Pack"
    "https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git ComfyUI-Impact-Subpack"
    "https://github.com/kijai/ComfyUI-KJNodes.git ComfyUI-KJNodes"
    "https://github.com/cubiq/ComfyUI_essentials.git ComfyUI_essentials"
    "https://github.com/cubiq/ComfyUI_IPAdapter_plus.git ComfyUI_IPAdapter_plus"
)

for repo in "${repos[@]}"; do
    url=$(echo $repo | awk '{print $1}')
    dir=$(echo $repo | awk '{print $2}')

    cd /home/ComfyUI/custom_nodes/ || exit
    git clone $url
    
    if ! cd "/home/ComfyUI/custom_nodes/$dir"; then
        echo "Warning: Could not enter directory /home/ComfyUI/custom_nodes/$dir. Skipping dependency installation for this repo."
        continue
    fi

    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt
    fi
done

echo "All Custom Nodes have been installed"