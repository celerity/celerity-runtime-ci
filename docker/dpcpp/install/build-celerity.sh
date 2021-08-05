#!/bin/sh

set -e

usage() {
    echo "Usage: $0 <cmake-build-type>" >&2
    exit 1
}

if [ $# -ne 1 ]; then usage; fi
BUILD_TYPE="$1"

export CCACHE_DIR=/ccache

# TODO this is a stub
cmake /src -B /build \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache

N_CORES=$(getconf _NPROCESSORS_ONLN)
cmake --build /build -j$N_CORES

