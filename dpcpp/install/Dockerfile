ARG UBUNTU
ARG INTEL_COMPUTE_RT
FROM intel-compute-rt:${INTEL_COMPUTE_RT}-ubuntu${UBUNTU}

COPY --chown=root:root common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh curl cmake ccache gdb python3 \
        ca-certificates python3 libstdc++-dev libgcc-dev libc6-dev ninja-build

COPY opt/dpcpp /opt/dpcpp
COPY VERSION /VERSION

RUN echo /opt/dpcpp/lib > /etc/ld.so.conf.d/dpcpp.conf \
    && ldconfig

# CCACHE_DEPEND=1 works around https://github.com/intel/llvm/issues/5260
ENV PATH="/opt/dpcpp/bin:${PATH}" \
    CCACHE_DIR=/ccache \
    CCACHE_DEPEND=1 \
    CCACHE_MAXSIZE=10G