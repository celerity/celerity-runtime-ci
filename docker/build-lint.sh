#!/bin/bash

set -eu -o pipefail

WORKING_DIR="$(readlink -f "$(dirname "$0")")/lint"
cd "$WORKING_DIR"
cp -r ../common .

docker build . --tag "celerity-lint:latest"
