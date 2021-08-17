FROM ubuntu:20.04

COPY --chown=root:root common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh cmake clang-10 ccache libopenmpi-dev openmpi-bin ocl-icd-opencl-dev \
        opencl-headers intel-opencl-icd libhdf5-openmpi-103 libhdf5-openmpi-dev pkg-config

COPY --chown=root:root opt/computecpp /opt/computecpp

COPY --chown=root:root VERSION /VERSION
COPY --chown=root:root common/build-with-cmake.sh /root/build-with-cmake.sh
COPY --chown=root:root build-celerity.sh /root/build-celerity.sh
COPY --chown=root:root common/data /data

ENV OMPI_ALLOW_RUN_AS_ROOT=1 OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
ENV PATH="/opt/computecpp/bin:${PATH}" CCACHE_DIR=/ccache/computecpp
