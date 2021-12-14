FROM ubuntu:20.04

COPY --chown=root:root common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh --base --cleanup curl libopenmpi-dev openmpi-bin pkg-config \
        libhdf5-openmpi-103 libhdf5-openmpi-dev cmake ccache

ARG IGC_VER=1.0.8365 \
    CRT_VER=21.34.20767 \
    CRT_L0_VER=1.1.20767 \
    CRT_GMMLIB_VER=21.2.1

ARG IGC_URL="https://github.com/intel/intel-graphics-compiler/releases/download/igc-${IGC_VER}" \
    CRT_URL="https://github.com/intel/compute-runtime/releases/download/${CRT_VER}"

RUN mkdir /root/intel \
    && cd /root/intel \
    && curl -LOSsf "${IGC_URL}/intel-igc-core_${IGC_VER}_amd64.deb" \
    && curl -LOSsf "${IGC_URL}/intel-igc-opencl_${IGC_VER}_amd64.deb" \
    && curl -LOSsf "${CRT_URL}/intel-gmmlib_${CRT_GMMLIB_VER}_amd64.deb" \
    && curl -LOSsf "${CRT_URL}/intel-opencl_${CRT_VER}_amd64.deb" \
    && curl -LOSsf "${CRT_URL}/intel-ocloc_${CRT_VER}_amd64.deb" \
    && curl -LOSsf "${CRT_URL}/intel-level-zero-gpu_${CRT_L0_VER}_amd64.deb" \
    && dpkg -i *.deb \
    && cd /root \
    && rm -rf intel

COPY --chown=root:root opt/dpcpp /opt/dpcpp
COPY --chown=root:root VERSION /VERSION
COPY --chown=root:root common/build-with-cmake.sh /root/build-with-cmake.sh
COPY --chown=root:root common/build-celerity.sh /root/build-celerity.sh
COPY --chown=root:root common/build-examples.sh /root/build-examples.sh
COPY --chown=root:root build-options.sh /root/build-options.sh
COPY --chown=root:root common/data /data

RUN ldconfig /opt/dpcpp/lib

ENV OMPI_ALLOW_RUN_AS_ROOT=1 \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
    PATH="/opt/dpcpp/bin:${PATH}" \
    CCACHE_DIR=/ccache/dpcpp
