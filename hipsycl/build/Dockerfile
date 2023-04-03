ARG UBUNTU
ARG CUDA
FROM nvidia/cuda:${CUDA}-devel-ubuntu${UBUNTU}

COPY common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh clang libclang-dev llvm-dev libomp-dev \
        cmake make ccache libboost-context-dev libboost-fiber-dev lld

COPY common/build-with-cmake.sh build-hipsycl.sh /root/

RUN mkdir /ccache && \
    mkdir -p /opt/hipsycl
ENV CCACHE_DIR=/ccache
CMD sh /root/build-hipsycl.sh
