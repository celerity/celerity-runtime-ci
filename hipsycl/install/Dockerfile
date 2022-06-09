ARG UBUNTU
ARG CUDA
FROM nvidia/cuda:${CUDA}-devel-ubuntu${UBUNTU}

# HACK: CUDA 11 no longer includes the "version.txt" file used by Clang to
# determine compatibility, which leads it to assume CUDA version 7.0.
#
# While this has been fixed in some newer LLVM release (see
# https://reviews.llvm.org/D89752) for Clang 10 we have to
# manually create this file.
RUN echo "CUDA Version ${CUDA}" > /usr/local/cuda/version.txt

# libomp-dev: package name is substituted by install-system.sh
COPY common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh cmake clang ccache libopenmpi-dev openmpi-bin libomp-dev \
        libhdf5-openmpi-103 libhdf5-openmpi-dev pkg-config libboost-all-dev \
        gdb lld make git ca-certificates python3

COPY opt/hipsycl /opt/hipsycl

COPY VERSION /VERSION
COPY common/build-with-cmake.sh common/build-ndzip.sh common/build-celerity.sh \
        common/build-examples.sh common/capture-backtrace.sh build-options.sh /root/
COPY common/data /data

ENV OMPI_ALLOW_RUN_AS_ROOT=1 OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
ENV PATH="/opt/hipsycl/bin:${PATH}" CCACHE_DIR=/ccache/hipsycl
