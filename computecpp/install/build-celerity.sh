#!/bin/sh

set -eu
sh /root/build-with-cmake.sh "$@" -- \
    -DCELERITY_SYCL_IMPL=ComputeCpp \
    -DComputeCpp_DIR="/opt/computecpp" \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache

