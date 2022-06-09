#!/bin/bash

CELERITY_BUILD_OPTS=(
    -DCELERITY_SYCL_IMPL=ComputeCpp
    -DComputeCpp_DIR="/opt/computecpp"
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
    -DCMAKE_C_COMPILER_LAUNCHER=ccache
    -DCMAKE_INSTALL_PREFIX=/root/celerity-install
)

EXAMPLES_BUILD_OPTS=(
    -DCMAKE_PREFIX_PATH=/root/celerity-install/lib/cmake
    -DComputeCpp_DIR="/opt/computecpp"
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
    -DCMAKE_C_COMPILER_LAUNCHER=ccache
)

