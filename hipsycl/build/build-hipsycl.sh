#!/bin/sh

set -eu
rm -rf /opt/hipsycl/*
bash /patches/apply.sh
bash ~/build-with-cmake.sh /root/build /src --target install -- \
    -DCMAKE_PREFIX_PATH=/usr/lib/llvm-10/lib/cmake/llvm \
    -DWITH_CUDA_BACKEND=YES \
    -DWITH_ROCM_BACKEND=NO \
    -DWITH_OPENCL_BACKEND=NO \
    -DCMAKE_INSTALL_PREFIX=/opt/hipsycl \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache

