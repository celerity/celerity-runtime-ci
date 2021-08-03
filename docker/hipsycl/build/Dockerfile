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
    && apt install -y --no-install-recommends git ca-certificates build-essential clang-10 libclang-10-dev llvm-10-dev cmake python3 ccache libboost-all-dev

COPY --chown=root:root build-hipsycl.sh /root/build-hipsycl.sh
CMD sh /root/build-hipsycl.sh
