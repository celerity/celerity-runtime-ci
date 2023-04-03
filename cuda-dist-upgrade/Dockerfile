ARG UBUNTU_BASE
ARG CUDA
FROM nvidia/cuda:${CUDA}-devel-ubuntu${UBUNTU_BASE}

ARG FROM_CODENAME TO_CODENAME
RUN export DEBIAN_FRONTEND=noninteractive \
    && sed -i "s/\\<$FROM_CODENAME\\>/$TO_CODENAME/g" /etc/apt/sources.list \
    && apt-get -q update \
    && apt-get -q full-upgrade -y \
    && apt-get -y autoremove \
    && apt-get -q clean \
    && rm -rf /var/lib/apt/lists/*
