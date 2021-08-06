FROM ubuntu:20.04

COPY install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh git ca-certificates clang-10 cmake ccache 

COPY --chown=root:root build-dpcpp.sh /home/user/build-dpcpp.sh

USER user
CMD sh /home/user/build-dpcpp.sh

