#!/bin/sh

set -eu
rm -rf /opt/dpcpp/*
sh ~/build-with-cmake.sh /src/llvm --target install -- \
    -DLLVM_ENABLE_PROJECTS='clang' \
    -DCMAKE_INSTALL_PREFIX=/opt/dpcpp \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache

