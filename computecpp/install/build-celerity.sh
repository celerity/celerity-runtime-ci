#!/bin/sh

set -eu

# Workaround for https://bugs.launchpad.net/ubuntu/+source/openmpi/+bug/1941786
export LDFLAGS=-lopen-pal

sh /root/build-with-cmake.sh "$@" -- \
    -DCELERITY_SYCL_IMPL=ComputeCpp \
    -DComputeCpp_DIR="/opt/computecpp" \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCELERITY_EXAMPLES_REQUIRE_HDF5=ON

