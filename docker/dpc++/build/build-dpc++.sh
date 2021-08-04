#!/bin/sh

set -xe

export CCACHE_DIR=/ccache

cmake /src/llvm -B /build \
    -DLLVM_ENABLE_PROJECTS='clang' \
    -DCMAKE_INSTALL_PREFIX=/opt/dpc++ \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache

rm -rf /opt/dpc++

N_CORES=$(getconf _NPROCESSORS_ONLN)
cmake --build /build -j$N_CORES --target install

