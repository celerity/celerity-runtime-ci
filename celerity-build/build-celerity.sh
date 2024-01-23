#!/bin/bash

set -eu

source /root/celerity-options.sh "$@"

# Workaround for https://bugs.launchpad.net/ubuntu/+source/openmpi/+bug/1941786
export LDFLAGS=-lopen-pal

# Export compile commands for clang-tidy checks
bash /root/build-with-cmake.sh /root/build "$@" -- \
    "${CELERITY_BUILD_OPTS[@]}" \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCELERITY_EXAMPLES_REQUIRE_HDF5=ON \

