#!/bin/sh

set -e

export CCACHE_DIR=/ccache

cmake /src/llvm -B /home/user/build \
    -DLLVM_ENABLE_PROJECTS='clang' \
    -DCMAKE_INSTALL_PREFIX=/opt/dpcpp \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache

rm -rf /opt/dpcpp

N_CORES=$(getconf _NPROCESSORS_ONLN)
cmake --build /home/user/build -j$N_CORES --target install

