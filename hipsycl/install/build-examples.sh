#!/bin/sh

set -eu

# Workaround for https://bugs.launchpad.net/ubuntu/+source/openmpi/+bug/1941786
export LDFLAGS=-lopen-pal

sh /root/build-with-cmake.sh /root/build-examples "$@" -- \
    -DCMAKE_PREFIX_PATH="/opt/hipsycl/lib/cmake;/root/celerity-install/lib/cmake" \
    -DHIPSYCL_TARGETS=cuda:sm_75 \
    -DCELERITY_EXAMPLES_REQUIRE_HDF5=ON

    # TODO ccache is currently broken for hipSYCL because it uses compiler launchers internally
    # -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    # -DCMAKE_C_COMPILER_LAUNCHER=ccache

