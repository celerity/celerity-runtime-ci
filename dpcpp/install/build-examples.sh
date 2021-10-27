#!/bin/sh

set -eu

# Workaround for https://bugs.launchpad.net/ubuntu/+source/openmpi/+bug/1941786
export LDFLAGS=-lopen-pal

sh /root/build-with-cmake.sh /root/build-examples "$@" -- \
    -DCMAKE_PREFIX_PATH=/root/celerity-install/lib/cmake \
    -DCMAKE_C_COMPILER=/opt/dpcpp/bin/clang \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER=/opt/dpcpp/bin/clang++ \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCELERITY_EXAMPLES_REQUIRE_HDF5=ON

