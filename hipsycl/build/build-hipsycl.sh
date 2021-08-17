#!/bin/sh

set -eu
rm -rf /opt/hipsycl/*
sh ~/build-with-cmake.sh /src --target install -- \
    -DCMAKE_PREFIX_PATH=/usr/lib/llvm-10/lib/cmake/llvm \
    -DWITH_CUDA_BACKEND=YES \
    -DCMAKE_INSTALL_PREFIX=/opt/hipsycl \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache

