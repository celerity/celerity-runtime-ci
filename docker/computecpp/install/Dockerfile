FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update \
    && apt full-upgrade -y \
    && apt install -y --no-install-recommends build-essential cmake python3 \
        clang-10 ccache libopenmpi-dev openmpi-bin ocl-icd-opencl-dev opencl-headers \
        intel-opencl-icd \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-10 20 \
        --slave /usr/bin/clang++ clang++ /usr/bin/clang++-10

COPY --chown=root:root build-celerity.sh /root/build-celerity.sh
COPY --chown=root:root opt/computecpp /opt/computecpp
COPY --chown=root:root VERSION /VERSION

ENV PATH="/opt/computecpp/bin:${PATH}"

