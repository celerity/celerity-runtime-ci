FROM ubuntu:20.04

COPY common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh python3 clang lld cmake ccache pkg-config ninja-build \
        git ca-certificates

COPY common/build-with-cmake.sh build-dpcpp.sh /root/

RUN mkdir /ccache && \
    mkdir -p /opt/dpcpp
ENV CCACHE_DIR=/ccache CCACHE_MAXSIZE=10G
CMD sh /root/build-dpcpp.sh
