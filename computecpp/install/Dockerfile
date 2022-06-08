FROM ubuntu:20.04

COPY common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh cmake clang ccache libopenmpi-dev openmpi-bin \
        ocl-icd-opencl-dev opencl-headers intel-opencl-icd libhdf5-openmpi-103 \
        libhdf5-openmpi-dev pkg-config gdb lld make git ca-certificates python3 \
        libboost-all-dev libtinfo5  # for ComputeCpp 2.7.0-experimental only

COPY opt/computecpp /opt/computecpp

COPY VERSION /VERSION
COPY common/build-with-cmake.sh common/build-ndzip.sh common/build-celerity.sh \
        common/build-examples.sh build-options.sh common/capture-backtrace.sh /root/
COPY common/data /data

ENV OMPI_ALLOW_RUN_AS_ROOT=1 OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
ENV PATH="/opt/computecpp/bin:${PATH}" CCACHE_DIR=/ccache/computecpp
