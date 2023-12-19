ARG UBUNTU
ARG SYCL
ARG SYCL_REF
FROM ghcr.io/celerity/celerity-build/${SYCL}:ubuntu${UBUNTU}-${SYCL_REF}

COPY common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh clang clang-format clang-tidy git ca-certificates
