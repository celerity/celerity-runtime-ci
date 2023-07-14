#!/bin/bash

NDZIP_BUILD_OPTS=(
    -DCMAKE_C_COMPILER="/usr/bin/clang"
    -DCMAKE_C_COMPILER_LAUNCHER=ccache
    -DCMAKE_CXX_COMPILER="/usr/bin/clang++"
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
    -DCMAKE_PREFIX_PATH="/opt/hipsycl/lib/cmake"
    -DHIPSYCL_TARGETS=cuda:sm_75
)

