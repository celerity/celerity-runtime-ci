#!/bin/bash

set -eu

source /root/build-options.sh

# Workaround for https://bugs.launchpad.net/ubuntu/+source/openmpi/+bug/1941786
export LDFLAGS=-lopen-pal

# TODO remove this block once the new example CMake structure is merged
if ! [ -f "$1/matmul/CMakeLists.txt" ]; then
    bash /root/build-with-cmake.sh /root/build-examples "$@" -- \
        "${EXAMPLES_BUILD_OPTS[@]}" \
        -DCELERITY_EXAMPLES_REQUIRE_HDF5=ON
    exit
fi

RETURN=0
cd "$(readlink -f $1)"; shift
for EXAMPLE in *; do
    if ! [ -d "$EXAMPLE" ]; then continue; fi
    echo -e "\n\n ---- Building example $EXAMPLE ----\n"
    BUILD_DIR="/root/build-examples/$EXAMPLE"
    if ! bash /root/build-with-cmake.sh "$BUILD_DIR" "$EXAMPLE" "$@" -- \
            "${EXAMPLES_BUILD_OPTS[@]}" 2> cmake-errors.log; then
        cat cmake-errors.log >&2
        if grep -q 'Skip this example' cmake-errors.log; then
            echo -e " ---- (Skipped example $EXAMPLE as instructed by CMake)"
        else
            RETURN=1
        fi
    fi
done
exit $RETURN

