ARG SYCL_IMAGE
FROM ${SYCL_IMAGE}

RUN bash /root/install-system.sh git ca-certificates lld gdb catch2 \
		libboost-container-dev libboost-thread-dev libboost-program-options-dev \
		zlib1g-dev liblz4-dev libzstd-dev lzma-dev

COPY common/build-with-cmake.sh build-ndzip.sh common/capture-backtrace.sh \
		ndzip-options.sh /root/
