FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_PREFER_BINARY=1 \
    PYTHONUNBUFFERED=1 \
    PYTHON_VERSION=3.12.3

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /

# Установка Python 3.12 и системных зависимостей
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
      wget \
      git \
      mc \
      build-essential \
      libssl-dev \
      zlib1g-dev \
      libbz2-dev \
      libreadline-dev \
      libsqlite3-dev \
      libncursesw5-dev \
      tk-dev \
      libxml2-dev \
      libxmlsec1-dev \
      libffi-dev \
      liblzma-dev \
      libglib2.0-0 \
      libsm6 \
      libgl1 \
      libxrender1 \
      libxext6 \
      ffmpeg \
      libgoogle-perftools4 \
      libtcmalloc-minimal4 \
      procps \
      nvidia-cuda-toolkit && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean -y

# Компиляция Python 3.12
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz && \
    tar -xf Python-${PYTHON_VERSION}.tar.xz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf Python-${PYTHON_VERSION} Python-${PYTHON_VERSION}.tar.xz

# Создаем симлинк python3.12 -> python
RUN ln -fs /usr/local/bin/python3.12 /usr/local/bin/python && \
    ln -fs /usr/local/bin/python3.12 /usr/local/bin/python3 && \
    ln -fs /usr/local/bin/pip3.12 /usr/local/bin/pip

# Установка torch для CUDA 12.4 с Python 3.12
RUN pip install --no-cache-dir \
    torch==2.6.0 \
    torchvision==0.21.0 \
    torchaudio==2.6.0 \
    --index-url https://download.pytorch.org/whl/cu124

# Базовые зависимости (обновлены для совместимости с PyTorch 2.6.0)
RUN pip install --no-cache-dir \
    opencv-python-headless==4.10.0.84 \
    pillow==10.4.0 \
    transformers==4.46.0 \
    peft==0.13.0 \
    diffusers==0.31.0 \
    safetensors==0.4.5 \
    aiohttp==3.10.8 \
    numpy==1.26.4 \
    color-matcher==0.6.0 \
    accelerate==1.1.0

# Установка Jupyter
RUN pip install --no-cache-dir \
    jupyter==1.1.1 \
    jupyterlab==4.2.6 \
    notebook==7.2.2 \
    ipywidgets==8.1.5

# Установка ComfyUI
WORKDIR /home
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

WORKDIR /home/ComfyUI
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

# Установка кастомных нод
WORKDIR /home/ComfyUI/custom_nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git && \
    git clone https://github.com/VisionExp/ComfyUI-Hunyuan3DWrapper-Linux.git

# Установка зависимостей для нод
WORKDIR /home/ComfyUI/custom_nodes/ComfyUI-Manager
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt
WORKDIR /home/ComfyUI/custom_nodes/ComfyUI-Hunyuan3DWrapper-Linux
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt \



RUN mkdir -p /root/.config/Ultralytics && chmod 755 /root/.config/Ultralytics
# Настройка Jupyter
RUN mkdir -p /root/.jupyter && \
    jupyter notebook --generate-config && \
    echo "c.NotebookApp.password = ''" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.token = ''" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.ip = '0.0.0.0'" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.notebook_dir = '/home/ComfyUI'" >> /root/.jupyter/jupyter_notebook_config.py

EXPOSE 8188 8888

COPY setup.sh /home/setup.sh
RUN chmod +x /home/setup.sh
CMD ["/home/setup.sh"]

COPY startup.sh /home/startup.sh
RUN chmod +x /home/startup.sh

CMD ["/home/startup.sh"]