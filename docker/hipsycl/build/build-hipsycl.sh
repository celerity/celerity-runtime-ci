#!/bin/sh

set -e

export CCACHE_DIR=/ccache

cmake /src -B /build \
    -DCMAKE_PREFIX_PATH=/usr/lib/llvm-10/lib/cmake/llvm \
    -DWITH_CUDA_BACKEND=YES \
    -DCMAKE_INSTALL_PREFIX=/opt/hipsycl \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache

N_CORES=$(getconf _NPROCESSORS_ONLN)
cmake --build /build -j$N_CORES --target install

