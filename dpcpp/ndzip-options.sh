#!/bin/bash

# We use Ninja instead of GNU Make to generate dependency files that are needed by ccache
# in depend_mode. See Dockerfile and https://github.com/intel/llvm/issues/5260.

NDZIP_BUILD_OPTS=(
    -DCMAKE_C_COMPILER=/opt/dpcpp/bin/clang
    -DCMAKE_C_COMPILER_LAUNCHER=ccache
    -DCMAKE_CXX_COMPILER=/opt/dpcpp/bin/clang++
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
    -G Ninja
)
