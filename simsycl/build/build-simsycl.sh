#!/bin/sh

set -eu

rm -rf /opt/simsycl

bash ~/build-with-cmake.sh /root/build /src --build-type Debug --target install -- \
    -G Ninja \
    -DCMAKE_INSTALL_PREFIX=/opt/simsycl/debug \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DSIMSYCL_ANNOTATE_SYCL_DEPRECATIONS=OFF \
    -DSIMSYCL_ENABLE_ASAN=ON

bash ~/build-with-cmake.sh /root/build /src --build-type Release --target install -- \
    -G Ninja \
    -DCMAKE_INSTALL_PREFIX=/opt/simsycl/release \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DSIMSYCL_ANNOTATE_SYCL_DEPRECATIONS=OFF
