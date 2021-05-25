#!/bin/bash
set -o xtrace -o errexit -o pipefail -o noclobber -o nounset

./build.sh nuc21 --intel --enable-computecpp

