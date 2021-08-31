#!/bin/sh

set -eu

# Workaround for https://bugs.launchpad.net/ubuntu/+source/openmpi/+bug/1941786
export LDFLAGS=-lopen-pal

sh /root/build-with-cmake.sh "$@" -- \
    -DCMAKE_C_COMPILER=/opt/dpcpp/bin/clang \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER=/opt/dpcpp/bin/clang++ \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCELERITY_SYCL_IMPL=DPC++ \
    -DCELERITY_EXAMPLES_REQUIRE_HDF5=ON

