ARG UBUNTU
FROM ubuntu:${UBUNTU}

COPY --chown=root:root common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh curl cmake ccache gdb python3 \
        ca-certificates python3 libstdc++-dev libgcc-dev libc6-dev ninja-build

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

COPY opt/dpcpp /opt/dpcpp
COPY VERSION /VERSION

RUN echo /opt/dpcpp/lib > /etc/ld.so.conf.d/dpcpp.conf \
    && ldconfig

# CCACHE_DEPEND=1 works around https://github.com/intel/llvm/issues/5260
ENV PATH="/opt/dpcpp/bin:${PATH}" \
    CCACHE_DIR=/ccache/dpcpp \
    CCACHE_DEPEND=1
