#!/bin/sh

set -eu

rm -rf /opt/dpcpp/*

python3 /src/buildbot/configure.py \
    --src-dir=/src \
    --obj-dir=/root/build \
    --cmake-opt=-DCMAKE_INSTALL_PREFIX=/opt/dpcpp \
    --cmake-opt=-DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    --cmake-opt=-DCMAKE_C_COMPILER_LAUNCHER=ccache

python3 /src/buildbot/compile.py \
    --src-dir=/src \
    --obj-dir=/root/build \
