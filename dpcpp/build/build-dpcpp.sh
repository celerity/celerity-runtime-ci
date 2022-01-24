#!/bin/bash

set -eu

rm -rf /opt/dpcpp/*

MORE_CONFIG_ARGS=()
# --disable-esimd-emulator: https://github.com/intel/llvm/issues/5360
if python3 /src/buildbot/configure.py --help | grep -q -- --disable-esimd-emulator; then
    MORE_CONFIG_ARGS+=(--disable-esimd-emulator)
fi

python3 /src/buildbot/configure.py \
    --src-dir=/src \
    --obj-dir=/root/build \
    --cmake-opt=-DCMAKE_INSTALL_PREFIX=/opt/dpcpp \
    --cmake-opt=-DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    --cmake-opt=-DCMAKE_C_COMPILER_LAUNCHER=ccache \
    "${MORE_CONFIG_ARGS[@]}"

python3 /src/buildbot/compile.py \
    --src-dir=/src \
    --obj-dir=/root/build \
