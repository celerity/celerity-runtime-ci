#!/bin/sh

set -eu
sh /root/build-with-cmake.sh "$@" -- \
    -DCMAKE_C_COMPILER=/opt/dpcpp/bin/clang \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER=/opt/dpcpp/bin/clang++ \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCELERITY_SYCL_IMPL=DPC++

