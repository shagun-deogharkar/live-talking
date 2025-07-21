# # Copyright (c) 2020-2022, NVIDIA CORPORATION.  All rights reserved.
# #
# # NVIDIA CORPORATION and its licensors retain all intellectual property
# # and proprietary rights in and to this software, related documentation
# # and any modifications thereto.  Any use, reproduction, disclosure or
# # distribution of this software and related documentation without an express
# # license agreement from NVIDIA CORPORATION is strictly prohibited.

# ARG BASE_IMAGE=nvcr.io/nvidia/cuda:11.6.1-cudnn8-devel-ubuntu20.04
# FROM $BASE_IMAGE

# RUN apt-get update -yq --fix-missing \
#  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
#     pkg-config \
#     wget \
#     cmake \
#     curl \
#     git \
#     vim

# #ENV PYTHONDONTWRITEBYTECODE=1
# #ENV PYTHONUNBUFFERED=1

# # nvidia-container-runtime
# #ENV NVIDIA_VISIBLE_DEVICES all
# #ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,graphics

# RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
# RUN sh Miniconda3-latest-Linux-x86_64.sh -b -u -p ~/miniconda3

# # RUN ~/miniconda3/bin/conda init
# # RUN source ~/.bashrc
# # RUN conda create -n nerfstream python=3.10
# # RUN conda activate nerfstream
# RUN ~/miniconda3/bin/conda create -y -n nerfstream python=3.10 \
#  && echo "source ~/miniconda3/bin/activate nerfstream" >> ~/.bashrc


# # RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
# # # install depend
# # RUN conda install pytorch==1.12.1 torchvision==0.13.1 cudatoolkit=11.3 -c pytorch
# # Copy requirements.txt ./
# # RUN pip install -r requirements.txt
# COPY requirements.txt ./

# RUN /bin/bash -c "source ~/miniconda3/bin/activate nerfstream && \
#     pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ && \
#     conda install -y pytorch==1.12.1 torchvision==0.13.1 cudatoolkit=11.3 -c pytorch && \
#     pip install -r requirements.txt"


# # # additional libraries
# # RUN pip install "git+https://github.com/facebookresearch/pytorch3d.git"
# # RUN pip install tensorflow-gpu==2.8.0

# # RUN pip uninstall protobuf
# # RUN pip install protobuf==3.20.1

# # RUN conda install ffmpeg
# # Copy ../python_rtmpstream /python_rtmpstream
# # WORKDIR /python_rtmpstream/python
# # RUN pip install .

# # Copy ../nerfstream /nerfstream
# # WORKDIR /nerfstream
# # CMD ["python3", "app.py"]

# # Copy modules (make sure these are inside the Docker build context!)
# COPY python_rtmpstream /python_rtmpstream
# COPY nerfstream /nerfstream

# # Install packages inside the conda environment
# RUN /bin/bash -c "source ~/miniconda3/bin/activate nerfstream && \
#     pip install 'git+https://github.com/facebookresearch/pytorch3d.git' && \
#     pip install tensorflow-gpu==2.8.0 && \
#     pip uninstall -y protobuf && \
#     pip install protobuf==3.20.1 && \
#     conda install -y ffmpeg"

# # Install local module from its correct folder
# WORKDIR /python_rtmpstream/python
# RUN /bin/bash -c "source ~/miniconda3/bin/activate nerfstream && pip install ."

# # Set final working directory
# WORKDIR /nerfstream
# CMD ["/root/miniconda3/envs/nerfstream/bin/python", "app.py"]

# --------------------------------------------------------------------------------------------

# # Base image with CUDA + cuDNN
# ARG BASE_IMAGE=nvcr.io/nvidia/cuda:11.6.1-cudnn8-devel-ubuntu20.04
# FROM $BASE_IMAGE

# # Install system dependencies
# RUN apt-get update -yq --fix-missing && \
#     DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
#     pkg-config wget cmake curl git vim libgl1

# # Install Miniconda
# RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
#     sh Miniconda3-latest-Linux-x86_64.sh -b -u -p ~/miniconda3

# # Create conda env with Python 3.10
# RUN ~/miniconda3/bin/conda create -y -n nerfstream python=3.10 && \
#     echo "source ~/miniconda3/bin/activate nerfstream" >> ~/.bashrc

# # Copy requirements
# COPY requirements.txt ./

# # Install Python + Conda dependencies
# RUN /bin/bash -c "source ~/miniconda3/bin/activate nerfstream && \
#     pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ && \
#     conda install -y pytorch==1.12.1 torchvision==0.13.1 cudatoolkit=11.3 -c pytorch && \
#     pip install -r requirements.txt && \
#     pip install 'git+https://github.com/facebookresearch/pytorch3d.git' && \
#     pip install tensorflow-gpu==2.8.0 && \
#     pip uninstall -y protobuf && \
#     pip install protobuf==3.20.1 && \
#     conda install -y ffmpeg"

# # OR (if you prefer static ffmpeg):
# RUN curl -L https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz \
#     | tar -xJ --strip-components=1 -C /usr/local/bin --wildcards '*/ffmpeg'

# # Upgrade transformers to match what diffusers expects
# RUN /bin/bash -c "source ~/miniconda3/bin/activate nerfstream && \
#     pip install --upgrade transformers"

# # Copy the rest of the codebase
# COPY . /app

# # Set working directory to project root
# WORKDIR /app

# # Run the main app
# CMD ["/root/miniconda3/envs/nerfstream/bin/python", "app.py"]


# --------------------------------------------------------------------------------------------

# Use base CUDA image
ARG BASE_IMAGE=nvcr.io/nvidia/cuda:11.4.2-cudnn8-devel-ubuntu20.04
FROM $BASE_IMAGE

# Install system dependencies (includes libgl1 for OpenCV)
RUN apt-get update -yq --fix-missing && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    pkg-config wget cmake curl git vim libgl1

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    sh Miniconda3-latest-Linux-x86_64.sh -b -u -p ~/miniconda3

# Create conda env with Python 3.10
RUN ~/miniconda3/bin/conda create -y -n nerfstream python=3.10 && \
    echo "source ~/miniconda3/bin/activate nerfstream" >> ~/.bashrc

# Set working directory and copy files
WORKDIR /app
COPY . /app

# Copy requirements.txt separately to leverage Docker cache
COPY requirements.txt ./

# Install Python + Conda + PIP dependencies
RUN /bin/bash -c "source ~/miniconda3/bin/activate nerfstream && \
    pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ && \
    pip install torch==1.12.1+cu113 torchvision==0.13.1+cu113 torchaudio==0.12.1 \
        -f https://download.pytorch.org/whl/torch_stable.html && \
    pip install -r requirements.txt && \
    pip install 'git+https://github.com/facebookresearch/pytorch3d.git' && \
    pip install tensorflow-gpu==2.8.0 && \
    pip uninstall -y protobuf && \
    pip install protobuf==3.20.1 && \
    pip install transformers==4.37.0"

# Download and install static ffmpeg binary
RUN curl -L https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz \
    | tar -xJ --strip-components=1 -C /usr/local/bin --wildcards '*/ffmpeg'

# Set FFMPEG_PATH for musetalk
ENV FFMPEG_PATH=/usr/local/bin/ffmpeg

# Default command to run your app
CMD ["/root/miniconda3/envs/nerfstream/bin/python", "app.py", "--transport", "webrtc", "--model", "wav2lip", "--avatar_id", "lipsync_shruti"]