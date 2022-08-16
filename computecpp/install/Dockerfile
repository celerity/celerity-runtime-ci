ARG UBUNTU
ARG INTEL_COMPUTE_RT
FROM intel-compute-rt:${INTEL_COMPUTE_RT}-ubuntu${UBUNTU}

COPY common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh cmake clang clang-tidy ccache ocl-icd-opencl-dev \
        opencl-headers intel-opencl-icd make python3 python3-pip \
        libtinfo5  # for ComputeCpp 2.7.0-experimental only

COPY opt/computecpp /opt/computecpp
COPY VERSION /VERSION

ENV PATH="/opt/computecpp/bin:${PATH}" CCACHE_DIR=/ccache/computecpp
