ARG UBUNTU
FROM ubuntu:${UBUNTU}

COPY common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh cmake ccache gcc g++ lld libboost-context-dev ninja-build

COPY opt/simsycl /opt/simsycl
COPY VERSION /VERSION

ENV CCACHE_DIR=/ccache \
    CCACHE_MAXSIZE=10G
