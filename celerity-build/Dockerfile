ARG SYCL_IMAGE
FROM ${SYCL_IMAGE}

RUN bash /root/install-system.sh git ca-certificates lld gdb pkg-config \
        libopenmpi-dev openmpi-bin libhdf5-openmpi-1* libhdf5-openmpi-dev \
        libc6-dbg libstdc++6-dbg python3 python3-pip curl lcov

RUN curl -L https://coveralls.io/coveralls-linux.tar.gz | tar -xz -C /usr/local/bin
RUN PIP_BREAK_SYSTEM_PACKAGES=1 pip install fastcov

COPY common/build-with-cmake.sh build-celerity.sh build-examples.sh \
        common/capture-backtrace.sh celerity-options.sh /root/
COPY data /data

ENV OMPI_ALLOW_RUN_AS_ROOT=1 OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
