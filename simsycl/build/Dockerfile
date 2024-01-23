ARG UBUNTU
FROM ubuntu:${UBUNTU}

COPY common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh g++ cmake ninja-build ccache libboost-context-dev lld \
    git ca-certificates

COPY common/build-with-cmake.sh build-simsycl.sh /root/

RUN mkdir /ccache
ENV CCACHE_DIR=/ccache \
    CCACHE_MAXSIZE=10G
CMD sh /root/build-simsycl.sh
