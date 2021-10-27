#!/bin/sh

set -eu

# Workaround for https://bugs.launchpad.net/ubuntu/+source/openmpi/+bug/1941786
export LDFLAGS=-lopen-pal

sh /root/build-with-cmake.sh /root/build "$@" -- \
    -DCELERITY_SYCL_IMPL=hipSYCL \
    -DCMAKE_PREFIX_PATH="/opt/hipsycl/lib/cmake" \
    -DHIPSYCL_TARGETS=cuda:sm_75 \
    -DCELERITY_EXAMPLES_REQUIRE_HDF5=ON \
    -DCMAKE_INSTALL_PREFIX=/root/celerity-install

    # TODO ccache is currently broken for hipSYCL because it uses compiler launchers internally
    # -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    # -DCMAKE_C_COMPILER_LAUNCHER=ccache

