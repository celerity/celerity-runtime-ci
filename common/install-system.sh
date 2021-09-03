#!/bin/bash

set -eu

unset BASE
unset CLEANUP
while [ $# -gt 0 ]; do
    case "$1" in
        --base) BASE=1; shift;;
        --cleanup) CLEANUP=1; shift;;
        --) shift; break;;
        *) break;;
    esac
done

export DEBIAN_FRONTEND=noninteractive
apt-get update
if [ -n "${BASE+x}" ]; then
    apt-get full-upgrade -y
    apt-get install -y --no-install-recommends build-essential python3 git ca-certificates
fi
if [ $# -gt 0 ]; then
    apt-get install -y --no-install-recommends "$@"
fi

if [ -n "${CLEANUP+x}" ]; then
    # Don't keep around apt cache in docker image
    apt-get clean
    rm -rf /var/lib/apt/lists/*
fi

if [[ " $@ " =~ " libhdf5-openmpi-dev " ]]; then
    # HDF5 pkg-config exports an incorrect include path, which CMake chokes on
    ln -s /usr/lib/x86_64-linux-gnu/openmpi/include/openmpi /usr/include/openmpi
fi

if [[ " $@ " =~ " clang-10 " ]]; then
    SLAVES=
    if [[ " $@ " =~ " clang-format-10 " ]]; then
        SLAVES+=" --slave /usr/bin/clang-format clang-format /usr/bin/clang-format-10"
    fi
    if [[ " $@ " =~ " clang-tidy-10 " ]]; then
        SLAVES+=" --slave /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-10"
    fi
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-10 20 \
        --slave /usr/bin/clang++ clang++ /usr/bin/clang++-10 \
        $SLAVES
fi

# Use GNU Gold for faster linking
update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.gold" 20
update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.bfd" 10

