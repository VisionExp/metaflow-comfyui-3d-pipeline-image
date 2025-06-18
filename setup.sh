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
    "https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git comfyui-advanced-controlnet"
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git comfyUI-custom-scripts"
    "https://github.com/kijai/ComfyUI-Florence2.git comfyui-florence2"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack.git comfyui-impact-pack"
    "https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git comfyui-impact-subpack"
    "https://github.com/kijai/ComfyUI-KJNodes.git comfyui-kjnodes"
    "https://github.com/cubiq/ComfyUI_essentials.git comfyui_essentials"
    "https://github.com/cubiq/ComfyUI_IPAdapter_plus.git comfyui_ipadapter_plus"
)

for repo in "${repos[@]}"; do
    url=$(echo $repo | awk '{print $1}')
    dir=$(echo $repo | awk '{print $2}')

    cd /home/ComfyUI/custom_nodes/ || exit
    git clone $url
    cd /home/ComfyUI/custom_nodes/$dir || exit
    pip install -r requirements.txt
done

echo "All Custom Nodes have been installed"