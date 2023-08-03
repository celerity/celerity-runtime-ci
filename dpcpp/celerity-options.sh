#!/bin/bash

# We use Ninja instead of GNU Make to generate dependency files that are needed by ccache
# in depend_mode. See Dockerfile and https://github.com/intel/llvm/issues/5260.

CELERITY_BUILD_OPTS=(
    -DCMAKE_C_COMPILER=/opt/dpcpp/bin/clang
    -DCMAKE_C_COMPILER_LAUNCHER=/usr/bin/ccache
    -DCMAKE_CXX_COMPILER=/opt/dpcpp/bin/clang++
    -DCMAKE_CXX_COMPILER_LAUNCHER=/usr/bin/ccache
    -DCELERITY_SYCL_IMPL=DPC++
    -DCMAKE_INSTALL_PREFIX=/root/celerity-install
    -G Ninja
)

EXAMPLES_BUILD_OPTS=(
    -DCMAKE_PREFIX_PATH=/root/celerity-install/lib/cmake
    -DCMAKE_C_COMPILER=/opt/dpcpp/bin/clang
    -DCMAKE_C_COMPILER_LAUNCHER=/usr/bin/ccache
    -DCMAKE_CXX_COMPILER=/opt/dpcpp/bin/clang++
    -DCMAKE_CXX_COMPILER_LAUNCHER=/usr/bin/ccache
    -G Ninja
)

