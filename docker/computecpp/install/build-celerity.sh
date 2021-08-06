#!/bin/sh

set -e

usage() {
    echo "Usage: $0 <cmake-build-type>" >&2
    exit 1
}

if [ $# -ne 1 ]; then usage; fi
BUILD_TYPE="$1"

export CCACHE_DIR=/ccache

cmake /src -B /home/user/build \
    -DComputeCpp_DIR="/opt/computecpp" \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache

N_CORES=$(getconf _NPROCESSORS_ONLN)
cmake --build /home/user/build -j$N_CORES

