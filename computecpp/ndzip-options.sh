#!/bin/bash

NDZIP_BUILD_OPTS=(
    -DCMAKE_C_COMPILER="/usr/bin/clang"
    -DCMAKE_CXX_COMPILER="/usr/bin/clang++"
    -DComputeCpp_DIR="/opt/computecpp"
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
    -DCMAKE_C_COMPILER_LAUNCHER=ccache
)

