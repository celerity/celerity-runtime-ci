#!/bin/sh

set -eu

usage() {
    echo "Usage: $0 <build-dir> <source-dir> [--target TARGET] [--build-type BUILD_TYPE] [-- <cmake-option>...]" >&2
    exit 1
}

if [ $# -lt 2 ]; then usage; fi
BUILD_DIR="$1"
SOURCE_DIR="$2"
shift

unset TARGET
BUILD_TYPE=Release
while [ $# -gt 0 ]; do
    case "$1" in
        --target) TARGET="$2"; shift 2;;
        --build-type) BUILD_TYPE="$2"; shift 2;;
        --) shift; break;;
        *) echo "Unexpected argument \"$1\"" >&2; usage; fi;;
    esac
done

N_CORES=$(getconf _NPROCESSORS_ONLN)

rm -rf "$BUILD_DIR"
cmake "$SOURCE_DIR" -B "$BUILD_DIR" "$@" -DCMAKE_BUILD_TYPE="$BUILD_TYPE"
cmake --build "$BUILD_DIR" -j$N_CORES ${TARGET+--target "$TARGET"}

