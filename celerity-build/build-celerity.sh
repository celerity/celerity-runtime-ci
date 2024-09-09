#!/bin/bash

set -eu

BUILD_OPTS=()
MPI_ENABLED=ON
while [ $# -ge 2 ]; do
    case "$1" in
        --mpi) MPI_ENABLED="$2"; shift 2;;
        --) break;;
        *) BUILD_OPTS+=("$1"); shift;;
    esac
done
BUILD_OPTS+=("$@")

source /root/celerity-options.sh "${BUILD_OPTS[@]}"

# Workaround for https://bugs.launchpad.net/ubuntu/+source/openmpi/+bug/1941786
export LDFLAGS=-lopen-pal

# Export compile commands for clang-tidy checks
bash /root/build-with-cmake.sh /root/build "${BUILD_OPTS[@]}" -- \
    -DCELERITY_ENABLE_MPI="$MPI_ENABLED" \
    "${CELERITY_BUILD_OPTS[@]}" \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCELERITY_EXAMPLES_REQUIRE_HDF5=ON \

