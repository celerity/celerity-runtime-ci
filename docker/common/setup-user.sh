#!/bin/bash

set -eu

usage() {
    echo "Usage: $0 [<UID>]" >&2
    exit 1
}

if [ $# -gt 1 ]; then usage; fi

if [ $# -eq 1 ]; then
    UID="$1"
    useradd --create-home --uid "$UID" user
else
    useradd --create-home user
fi
