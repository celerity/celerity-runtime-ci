#!/bin/sh

set -eu
sh /root/build-with-cmake.sh "$@" -- \
    -DCELERITY_SYCL_IMPL=hipSYCL \
    -DCMAKE_PREFIX_PATH="/opt/hipsycl/lib/cmake" \
    -DHIPSYCL_TARGETS=cuda:sm_75

    # TODO ccache is currently broken for hipSYCL because it uses compiler launchers internally
    # -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    # -DCMAKE_C_COMPILER_LAUNCHER=ccache

