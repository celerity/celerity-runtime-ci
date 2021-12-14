FROM nvidia/cuda:11.3.0-devel-ubuntu20.04

# HACK: CUDA 11 no longer includes the "version.txt" file used by Clang to
# determine compatibility, which leads it to assume CUDA version 7.0.
#
# While this has been fixed in some newer LLVM release (see
# https://reviews.llvm.org/D89752) for Clang 10 we have to
# manually create this file.
RUN echo "CUDA Version 11.3.0" > /usr/local/cuda/version.txt

COPY --chown=root:root common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh --base --cleanup cmake clang-10 ccache libopenmpi-dev \
        openmpi-bin libomp-10-dev libhdf5-openmpi-103 libhdf5-openmpi-dev pkg-config \
        libboost-context-dev libboost-fiber-dev

COPY --chown=root:root opt/hipsycl /opt/hipsycl

COPY --chown=root:root VERSION /VERSION
COPY --chown=root:root common/build-with-cmake.sh /root/build-with-cmake.sh
COPY --chown=root:root common/build-celerity.sh /root/build-celerity.sh
COPY --chown=root:root common/build-examples.sh /root/build-examples.sh
COPY --chown=root:root build-options.sh /root/build-options.sh
COPY --chown=root:root common/data /data

ENV OMPI_ALLOW_RUN_AS_ROOT=1 OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
ENV PATH="/opt/hipsycl/bin:${PATH}" CCACHE_DIR=/ccache/hipsycl
