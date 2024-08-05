ARG UBUNTU
ARG CUDA
FROM nvidia/cuda:${CUDA}-devel-ubuntu${UBUNTU}

COPY common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh clang libclang-dev llvm-dev libomp-dev \
        cmake make ccache libboost-context-dev libboost-fiber-dev lld \
        git ca-certificates

COPY common/build-with-cmake.sh build-acpp.sh /root/

RUN mkdir /ccache && \
    mkdir -p /opt/acpp
ENV CCACHE_DIR=/ccache \
    CCACHE_MAXSIZE=10G
CMD sh /root/build-acpp.sh
