#!/bin/bash

set -eu

source /root/build-options.sh

# Workaround for https://bugs.launchpad.net/ubuntu/+source/openmpi/+bug/1941786
export LDFLAGS=-lopen-pal

bash /root/build-with-cmake.sh /root/build "$@" -- \
    "${CELERITY_BUILD_OPTS[@]}" \
    -DCELERITY_EXAMPLES_REQUIRE_HDF5=ON \

