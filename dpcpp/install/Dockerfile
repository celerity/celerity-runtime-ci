FROM ubuntu:20.04

COPY --chown=root:root common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh libopenmpi-dev openmpi-bin pkg-config \
        libhdf5-openmpi-103 libhdf5-openmpi-dev cmake ccache ocl-icd-opencl-dev \
        opencl-headers intel-opencl-icd

COPY --chown=root:root opt/dpcpp /opt/dpcpp
COPY --chown=root:root VERSION /VERSION
COPY --chown=root:root common/build-with-cmake.sh /root/build-with-cmake.sh
COPY --chown=root:root build-celerity.sh /root/build-celerity.sh
COPY --chown=root:root common/data /data

RUN ldconfig /opt/dpcpp/lib

ENV OMPI_ALLOW_RUN_AS_ROOT=1 OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
ENV PATH="/opt/dpcpp/bin:${PATH}" CCACHE_DIR=/ccache/dpcpp
