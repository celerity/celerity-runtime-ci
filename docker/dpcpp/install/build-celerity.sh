#!/bin/sh

# TODO this is a stub
set -eu
sh /home/user/build-with-cmake.sh "$@" -- \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache

