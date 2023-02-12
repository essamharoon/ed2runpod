# Based off https://www.runpod.io/blog/diy-deep-learning-docker-container
FROM pytorch/pytorch:1.13.1-cuda11.6-cudnn8-devel

# Use bash shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND noninteractive\
    SHELL=/bin/bash

# Install base utilities and Python 3.10
# RUN apt-get update && apt-get upgrade -y && apt install software-properties-common -y && add-apt-repository ppa:deadsnakes/ppa && \
#     apt-get install -y wget git python3.10-dev python3.10-venv curl zip unzip git-lfs tmux vim kbd openssh-server && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/* && \
#     echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Install pip for Python 3.10
# RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10
# RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 0

# Install Pytorch 1.21.1 for CUDA 1.16
# RUN pip install torch==1.12.1+cu116 torchvision==0.13.1+cu116 --extra-index-url https://download.pytorch.org/whl/cu116

# Install required python modules
ADD requirements.txt .
RUN python3 --version && pip install -r requirements.txt

# Install transformers and upgrade requests
RUN pip install transformers -i https://pypi.python.org/simple
RUN pip install requests --upgrade
RUN pip install jupyterlab
RUN pip install ipywidgets

# Install xformers
RUN pip install --pre -U xformers

# Precache .cache with huggingface files
#RUN mkdir -p /root/.cache/huggingface/
#ADD cache/huggingface/* /root/.cache/huggingface/

# Add EveryDream repo
WORKDIR /
RUN git clone https://github.com/victorchall/EveryDream2trainer everydream2 && \
    cd everydream2 && \
    python3 utils/get_yamls.py

ADD start.sh /

RUN chmod +x /start.sh

CMD [ "/start.sh" ]
