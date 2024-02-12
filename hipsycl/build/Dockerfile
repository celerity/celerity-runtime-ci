ARG UBUNTU
ARG CUDA
FROM nvidia/cuda:${CUDA}-devel-ubuntu${UBUNTU}

COPY common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh clang libclang-dev llvm-dev libomp-dev \
        cmake make ccache libboost-context-dev libboost-fiber-dev lld \
        git ca-certificates

COPY common/build-with-cmake.sh build-hipsycl.sh /root/

# HACK: Until our minimum supported version includes https://github.com/AdaptiveCpp/AdaptiveCpp/pull/1276, we have to patch it in manually
COPY patches /patches/

RUN mkdir /ccache && \
    mkdir -p /opt/hipsycl
ENV CCACHE_DIR=/ccache \
    CCACHE_MAXSIZE=10G
CMD sh /root/build-hipsycl.sh
