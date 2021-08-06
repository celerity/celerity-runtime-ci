FROM ubuntu:20.04

COPY --chown=root:root common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh git ca-certificates clang-10 cmake ccache 

COPY --chown=root:root common/build-with-cmake.sh /home/user/build-with-cmake.sh
COPY --chown=root:root build-dpcpp.sh /home/user/build-dpcpp.sh

USER user
ENV CCACHE_DIR=/ccache
CMD sh /home/user/build-dpcpp.sh

