#!/bin/sh

set -eu

usage() {
    echo "Usage: $0 <source-dir> [--target=TARGET] [--build-type=BUILD_TYPE] [-- <cmake-option>...]" >&2
    exit 1
}

if [ $# -lt 1 ]; then usage; fi
SOURCE_DIR="$1"
shift

unset TARGET
BUILD_TYPE=Release
while true; do
    case "$1" in
		--target) TARGET="$2"; shift 2;;
		--build-type) BUILD_TYPE="$2"; shift 2;;
        --) shift; break;;
		*) echo "Unexpected argument \"$1\"" >&2; usage;;
    esac
done

N_CORES=$(getconf _NPROCESSORS_ONLN)

cmake "$SOURCE_DIR" -B /home/user/build "$@" -DCMAKE_BUILD_TYPE="$BUILD_TYPE"
cmake --build /home/user/build -j$N_CORES ${TARGET+--target "$TARGET"}

