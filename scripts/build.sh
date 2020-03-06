#!/bin/bash
set -e

if [ -z $2 ]; then
	echo "Usage: $0 [hipSYCL,ComputeCpp] [Debug,Release]"
	exit 1
fi

SYCL_IMPL=$1
BUILD_TYPE=$2

if [[ $SYCL_IMPL != "hipSYCL" && $SYCL_IMPL != "ComputeCpp" ]]; then
	echo "Invalid SYCL implementation \"$SYCL_IMPL\""
	exit 1
fi

if [[ $BUILD_TYPE != "Debug" && $BUILD_TYPE != "Release" ]]; then
	echo "Invalid build type \"$BUILD_TYPE\""
	exit 1
fi

if [[ $SYCL_IMPL = "hipSYCL" ]]; then
	cmake -G Ninja $GITHUB_WORKSPACE -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
		-DCMAKE_PREFIX_PATH="/sycl/hipSYCL/lib" \
		-DHIPSYCL_PLATFORM=cuda -DHIPSYCL_GPU_ARCH=sm_75
	ninja
fi

if [[ $SYCL_IMPL = "ComputeCpp" ]]; then
	cmake -G Ninja $GITHUB_WORKSPACE -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
		-DComputeCpp_DIR="/computecpp" -DCOMPUTECPP_BITCODE="ptx64" \
		-DCOMPUTECPP_USER_FLAGS="-fno-addrsig -no-serial-memop -Wno-sycl-undef-func" \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON # Required for clang-tidy
	ninja
fi

