FROM nvidia/cuda:11.3.0-devel-ubuntu20.04

# HACK: CUDA 11 no longer includes the "version.txt" file used by Clang to
# determine compatibility, which leads it to assume CUDA version 7.0.
#
# While this has been fixed in some newer LLVM release (see
# https://reviews.llvm.org/D89752) for Clang 10 we have to
# manually create this file.
RUN echo "CUDA Version 11.3.0" > /usr/local/cuda/version.txt

COPY install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh clang-10 libclang-10-dev llvm-10-dev cmake ccache \
		libboost-context-dev libboost-fiber-dev

COPY --chown=root:root build-hipsycl.sh /home/user/build-hipsycl.sh

USER user
CMD sh /home/user/build-hipsycl.sh

