#!/bin/sh

set -o errexit -o pipefail -o noclobber -o nounset

cd /src
# We have to try two different patches depending on which hipSYCL version is checked out, as `syclcc-clang` has recently been renamed to `acpp`
git apply /patches/1276_stable.patch || git apply /patches/1276_HEAD.patch
