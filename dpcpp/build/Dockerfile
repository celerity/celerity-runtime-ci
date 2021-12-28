FROM ubuntu:20.04

COPY common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh --base --cleanup clang-10 cmake ccache pkg-config ninja-build

COPY common/build-with-cmake.sh build-dpcpp.sh /root/

RUN mkdir /ccache && \
    mkdir -p /opt/dpcpp
ENV CCACHE_DIR=/ccache CCACHE_MAXSIZE=10G
CMD sh /root/build-dpcpp.sh
