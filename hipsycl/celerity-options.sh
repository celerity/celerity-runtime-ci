#!/bin/bash

CELERITY_BUILD_OPTS=(
    -DCMAKE_C_COMPILER=/usr/bin/clang
    -DCMAKE_C_COMPILER_LAUNCHER=/usr/bin/ccache
    -DCMAKE_CXX_COMPILER=/usr/bin/clang++
    -DCMAKE_CXX_COMPILER_LAUNCHER=/usr/bin/ccache
    -DCELERITY_SYCL_IMPL=hipSYCL 
    -DCMAKE_PREFIX_PATH=/opt/hipsycl
    -DHIPSYCL_TARGETS=cuda:sm_75
    -DCMAKE_INSTALL_PREFIX=/root/celerity-install
)

EXAMPLES_BUILD_OPTS=(
    -DCMAKE_C_COMPILER=/usr/bin/clang
    -DCMAKE_C_COMPILER_LAUNCHER=/usr/bin/ccache
    -DCMAKE_CXX_COMPILER=/usr/bin/clang++
    -DCMAKE_CXX_COMPILER_LAUNCHER=/usr/bin/ccache
    -DCMAKE_PREFIX_PATH="/opt/hipsycl;/root/celerity-install"
    -DHIPSYCL_TARGETS=cuda:sm_75
)

