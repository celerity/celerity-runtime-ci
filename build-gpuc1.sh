#!/bin/bash
set -o xtrace -o errexit -o pipefail -o noclobber -o nounset

./build.sh gpuc1 --nvidia --enable-hipsycl

