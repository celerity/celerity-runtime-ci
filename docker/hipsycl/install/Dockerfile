FROM nvidia/cuda:11.3.0-devel-ubuntu20.04

# HACK: CUDA 11 no longer includes the "version.txt" file used by Clang to
# determine compatibility, which leads it to assume CUDA version 7.0.
#
# While this has been fixed in some newer LLVM release (see
# https://reviews.llvm.org/D89752) for Clang 10 we have to
# manually create this file.
RUN echo "CUDA Version 11.3.0" > /usr/local/cuda/version.txt

ARG DEBIAN_FRONTEND=noninteractive 
RUN apt update \
    && apt full-upgrade -y \
    && apt install -y --no-install-recommends build-essential cmake python3 \
        clang-10 ccache libboost-all-dev libopenmpi-dev openmpi-bin libomp-10-dev \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-10 20 \
        --slave /usr/bin/clang++ clang++ /usr/bin/clang++-10

COPY --chown=root:root VERSION /VERSION
COPY --chown=root:root opt/hipsycl /opt/hipsycl
COPY --chown=root:root build-celerity.sh /root/build-celerity.sh

ENV PATH="/opt/hipsycl/bin:${PATH}"

