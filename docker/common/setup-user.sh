#!/bin/bash

set -eu

usage() {
    echo "Usage: $0 <UID>" >&2
    exit 1
}

if [ $# -ne 1 ]; then usage; fi

UID="$1"

useradd --create-home --uid "$UID" user
