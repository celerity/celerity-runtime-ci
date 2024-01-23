#!/bin/bash

get_build_type() {
    while [ $# -ge 2 ]; do
        if [ "$1" == "--build-type" ]; then echo -n "$2"; exit; fi
        shift
    done
    echo -n Release
}
BUILD_TYPE="$(get_build_type "$@" | tr '[:upper:]' '[:lower:]')"

CELERITY_BUILD_OPTS=(
    -G Ninja
    -DCMAKE_C_COMPILER=/usr/bin/gcc
    -DCMAKE_C_COMPILER_LAUNCHER=/usr/bin/ccache
    -DCMAKE_CXX_COMPILER=/usr/bin/g++
    -DCMAKE_CXX_COMPILER_LAUNCHER=/usr/bin/ccache
    -DCELERITY_SYCL_IMPL=SimSYCL
    -DCMAKE_PREFIX_PATH="/opt/simsycl/$BUILD_TYPE"
    -DCMAKE_INSTALL_PREFIX=/root/celerity-install
)

EXAMPLES_BUILD_OPTS=(
    -G Ninja
    -DCMAKE_C_COMPILER=/usr/bin/gcc
    -DCMAKE_C_COMPILER_LAUNCHER=/usr/bin/ccache
    -DCMAKE_CXX_COMPILER=/usr/bin/g++
    -DCMAKE_CXX_COMPILER_LAUNCHER=/usr/bin/ccache
    -DCMAKE_PREFIX_PATH="/opt/simsycl/$BUILD_TYPE;/root/celerity-install"
)
