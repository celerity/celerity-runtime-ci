#!/bin/bash

set -eu -o pipefail

usage() {
    echo "Usage: $0 <ubuntu-version> acpp|dpcpp <git-ref>" >&2
    echo "Builds the linting container on top of an existing celerity-build container." >&2
    exit 1
}

if [ $# -ne 3 ]; then usage; fi
UBUNTU="$1"
SYCL="$2"
SYCL_REF="$3"

WORKING_DIR="$(readlink -f "$(dirname "$0")")/lint"
cd "$WORKING_DIR"
cp -r ../common .

docker build . \
    --build-arg=UBUNTU="${UBUNTU}" \
    --build-arg=SYCL="${SYCL}" \
    --build-arg=SYCL_REF="${SYCL_REF}" \
    --tag "celerity-lint:latest"
