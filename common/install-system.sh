#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive
apt-get -q update
apt-get -q full-upgrade -y

PACKAGES=( "$@" )

source /etc/lsb-release

# Some package names depend on the LLVM version (=> Ubuntu version)
case "$DISTRIB_RELEASE" in
    20.04) LLVM=10 GCC=9;;
    22.04) LLVM=14 GCC=12;;
    *) echo "Unsupported Ubuntu version $DISTRIB_RELEASE">&2; exit 1;;
esac

# Substitute our made-up package names with Ubuntu versioned names
for i in "${!PACKAGES[@]}"; do
    case "${PACKAGES[i]}" in
        libomp-dev) PACKAGES[i]="libomp-$LLVM-dev";;
        libstdc++-dev) PACKAGES[i]="libstdc++-$GCC-dev";;
        libgcc-dev) PACKAGES[i]="libgcc-$GCC-dev";;
    esac
done

if [ $# -gt 0 ]; then
    apt-get -q install -y --no-install-recommends "${PACKAGES[@]}"
fi

# Don't keep around apt cache in docker image
apt-get -q clean
rm -rf /var/lib/apt/lists/*

if [ -d "/usr/lib/x86_64-linux-gnu/openmpi/include/openmpi" ]; then
    # HDF5 pkg-config exports an incorrect include path, which CMake chokes on
    ln -s /usr/lib/x86_64-linux-gnu/openmpi/include/openmpi /usr/include/openmpi
fi

# Use lld or GNU gold for faster linking
if [ -x "/usr/bin/ld.lld" ]; then
    update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.lld" 30
fi
if [ -x "/usr/bin/ld.gold" ]; then
    update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.gold" 20
fi
if [ -x "/usr/bin/ld.bfd" ]; then
    update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.bfd" 10
fi

if [ -d "/etc/gdb" ]; then
    echo 'set auto-load safe-path /' >> /etc/gdb/gdbinit
fi

