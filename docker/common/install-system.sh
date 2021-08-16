#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get full-upgrade -y
apt-get install -y --no-install-recommends build-essential python3 git "$@"

# Don't keep around apt cache in docker image
apt-get clean
rm -rf /var/lib/apt/lists/*

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

useradd -m user

