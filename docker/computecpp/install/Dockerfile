FROM ubuntu:20.04

ARG UID
COPY --chown=root:root common/setup-user.sh /root/setup-user.sh
RUN bash /root/setup-user.sh ${UID}

COPY --chown=root:root common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh cmake clang-10 ccache libopenmpi-dev openmpi-bin ocl-icd-opencl-dev \
        opencl-headers intel-opencl-icd libhdf5-openmpi-103 libhdf5-openmpi-dev pkg-config

COPY --chown=root:root common/build-with-cmake.sh /home/user/build-with-cmake.sh
COPY --chown=root:root build-celerity.sh /home/user/build-celerity.sh
COPY --chown=root:root opt/computecpp /opt/computecpp
COPY --chown=root:root VERSION /VERSION

RUN mkdir /ccache && chown -R user:user /ccache
ENV PATH="/opt/computecpp/bin:${PATH}" CCACHE_DIR=/ccache/computecpp
USER user

