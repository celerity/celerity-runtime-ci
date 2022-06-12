#!/bin/bash

CELERITY_BUILD_OPTS=(
    -DCELERITY_SYCL_IMPL=hipSYCL 
    -DCMAKE_PREFIX_PATH="/opt/hipsycl/lib/cmake"
    -DHIPSYCL_TARGETS=cuda:sm_75
    -DCMAKE_INSTALL_PREFIX=/root/celerity-install
)

EXAMPLES_BUILD_OPTS=(
    -DCMAKE_PREFIX_PATH="/opt/hipsycl/lib/cmake;/root/celerity-install/lib/cmake"
    -DHIPSYCL_TARGETS=cuda:sm_75
)

# TODO ccache is currently broken for hipSYCL because it uses compiler launchers internally
#     -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
#     -DCMAKE_C_COMPILER_LAUNCHER=ccache