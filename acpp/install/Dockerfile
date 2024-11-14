ARG UBUNTU
ARG CUDA
FROM nvidia/cuda:${CUDA}-devel-ubuntu${UBUNTU}

# FROM clears all ARG-bindings, restore $CUDA for usage below
ARG CUDA

# HACK: CUDA 11 no longer includes the "version.txt" file used by Clang to
# determine compatibility, which leads it to assume CUDA version 7.0.
#
# While this has been fixed in some newer LLVM release (see
# https://reviews.llvm.org/D89752) for Clang 10 we have to
# manually create this file.
RUN echo "CUDA Version $CUDA" > /usr/local/cuda/version.txt

# libomp-dev: package name is substituted by install-system.sh
COPY common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh cmake ccache clang clang-tidy libomp-dev \
        libboost-fiber-dev libboost-context-dev make python3

COPY opt/acpp /opt/acpp
COPY VERSION /VERSION

# CCACHE_DEPEND=1 works around https://github.com/ccache/ccache/issues/1488
ENV PATH="/opt/acpp/bin:${PATH}" \
    CCACHE_DIR=/ccache \
    CCACHE_DEPEND=1 \
    CCACHE_MAXSIZE=10G
