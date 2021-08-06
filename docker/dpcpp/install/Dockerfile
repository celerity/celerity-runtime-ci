FROM ubuntu:20.04

COPY install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh libopenmpi-dev openmpi-bin pkg-config \
		libhdf5-openmpi-103 libhdf5-openmpi-dev cmake ccache 

COPY --chown=root:root opt/dpcpp /opt/dpcpp
COPY --chown=root:root VERSION /VERSION
COPY --chown=root:root build-celerity.sh /home/user/build-celerity.sh

ENV PATH="/opt/dpcpp/bin:${PATH}"
USER user

