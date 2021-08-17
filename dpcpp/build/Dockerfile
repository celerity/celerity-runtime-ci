FROM ubuntu:20.04

COPY --chown=root:root common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh git ca-certificates clang-10 cmake ccache 

COPY --chown=root:root common/build-with-cmake.sh /root/build-with-cmake.sh
COPY --chown=root:root build-dpcpp.sh /root/build-dpcpp.sh

RUN mkdir /ccache && \
    mkdir -p /opt/dpcpp
ENV CCACHE_DIR=/ccache
CMD sh /root/build-dpcpp.sh
