#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get full-upgrade -y

if [ $# -gt 0 ]; then
    apt-get install -y --no-install-recommends "$@"
fi

# Don't keep around apt cache in docker image
apt-get clean
rm -rf /var/lib/apt/lists/*

if [[ " $@ " =~ " libhdf5-openmpi-dev " ]]; then
    # HDF5 pkg-config exports an incorrect include path, which CMake chokes on
    ln -s /usr/lib/x86_64-linux-gnu/openmpi/include/openmpi /usr/include/openmpi
fi

# Use lld or GNU gold for faster linking
if [[ " $@ " =~ " lld " ]]; then
    update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.lld" 30
fi
update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.gold" 20
update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.bfd" 10

if [[ " $@ " =~ " gdb " ]]; then
    echo 'set auto-load safe-path /' >> /etc/gdb/gdbinit
fi
