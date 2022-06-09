#!/bin/bash

NDZIP_BUILD_OPTS=(
    -DComputeCpp_DIR="/opt/computecpp"
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
    -DCMAKE_C_COMPILER_LAUNCHER=ccache
)

