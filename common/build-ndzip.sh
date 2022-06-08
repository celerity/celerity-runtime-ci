#!/bin/bash

set -eu

source /root/build-options.sh

bash /root/build-with-cmake.sh /root/build "$@" -- \
    "${NDZIP_BUILD_OPTS[@]}" \
    -DNDZIP_BUILD_TEST=ON \
    -DNDZIP_BUILD_BENCHMARK=ON

