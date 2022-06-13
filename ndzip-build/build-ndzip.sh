#!/bin/bash

set -eu

usage() {
    echo "Usage: $0 <source-dir> [--target TARGET] [--build-type BUILD_TYPE] [--cuda-toolchain clang|nvcc] [-- <cmake-option>...]" >&2
    exit 1
}

OPTIONS=()
unset CUDA_TOOLCHAIN
while [ $# -gt 0 ]; do
    case "$1" in
        --cuda-toolchain) CUDA_TOOLCHAIN="$2"; shift 2;;
        --) shift; break;;
        *) OPTIONS+=("$1"); shift;;
    esac
done

TOOLCHAIN_PARAMS=(-DCMAKE_CUDA_ARCHITECTURES=75)
case "$CUDA_TOOLCHAIN" in
    clang) TOOLCHAIN_PARAMS+=(-DCMAKE_CUDA_COMPILER=/usr/bin/clang);;
    nvcc) ;;
    *) echo "Unknown CUDA toolchain \"$CUDA_TOOLCHAIN\"" >&2; usage;;
esac

source /root/ndzip-options.sh

bash /root/build-with-cmake.sh /root/build "${OPTIONS[@]}" -- \
    "${TOOLCHAIN_PARAMS[@]}" \
    "${NDZIP_BUILD_OPTS[@]}" \
    -DNDZIP_BUILD_TEST=ON \
    -DNDZIP_BUILD_BENCHMARK=ON \
    "$@"

