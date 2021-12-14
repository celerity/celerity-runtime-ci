#!/bin/bash

CELERITY_BUILD_OPTS=(
    -DCMAKE_C_COMPILER=/opt/dpcpp/bin/clang \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER=/opt/dpcpp/bin/clang++ \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCELERITY_SYCL_IMPL=DPC++ \
    -DCMAKE_INSTALL_PREFIX=/root/celerity-install
)

EXAMPLES_BUILD_OPTS=(
    -DCMAKE_PREFIX_PATH=/root/celerity-install/lib/cmake \
    -DCMAKE_C_COMPILER=/opt/dpcpp/bin/clang \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER=/opt/dpcpp/bin/clang++ \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
)

