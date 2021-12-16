# Celerity Docker CI

Infrastructure for building and running Docker containers for Celerity CI.

This repository itself also uses GitHub actions to create new nightly builds
of CI containers for all supported SYCL implementations.

## Prerequisites

Due to security considerations and limitations of GitHub's workflow definition
files, we currently require the following prerequisites on the CI system:

- Docker must be run [_rootless_](https://docs.docker.com/engine/security/rootless)
    - The containers internally run as root, however this then just maps to
      the user running the container on the host (which should *NOT* be root, obviously).
- The `docker` executable must be _shimmed_ with our own [wrapper](docker-shim/docker)
    - Make sure the shimmed executable is found first in `$PATH`
    - The shimmed executable requires the environment variable
      `CELERITY_CI_DOCKER_CREATE_OPTIONS` to be set (it can be empty -- see
      below).

The [`check-prerequisites.sh`](check-prerequisites.sh) script can be used to
verify the setup.

## Building SYCL Container Images

To build a container for running Celerity CI for a given SYCL implementation,
use the [`build.sh`](build.sh) script.

The script creates two container images: One for building the SYCL
implementation itself, and another for subsequently compiling Celerity against
that SYCL implementation.

## Platform-Specific Setup

To run containers with GPU access, platform-specific setup is required. In
particular, different options need to be passed to `docker create` (or
equivalently `docker run`).

Since the GitHub workflow definition files are rather inflexible regarding
Docker options, we instead pass these options through the
`CELERITY_CI_DOCKER_CREATE_OPTIONS` environment variable picked up by the
shimmed Docker executable (see above).

### Running on Intel

To access Intel integrated GPUs, the device file needs to be mounted into the
container. Set `CELERITY_CI_DOCKER_CREATE_OPTIONS="--device=/dev/dri/render*"`
(where `*` should be expanded manually).

### Running on NVIDIA

Set `CELERITY_CI_DOCKER_CREATE_OPTIONS="--gpus=all"`.

To enable NVIDIA GPU passthrough, be sure to install the [NVIDIA Container
Runtime](https://nvidia.github.io/nvidia-container-runtime/).

To make GPU passthrough work for rootless, as of Docker 19.03, `cgroups` need to
be disabled. This can be done by providing the
`nvidia-container-runtime-hook-config.toml` file to the Docker runtime hook
using the `nvidia-container-runtime-hook` wrapper provided in this repository.

## Interaction with celerity-runtime CMake

Building and running examples against the installed Celerity Runtime is a bit finicky because which examples can be run depends on the exported configuration (e.g. `CELERITY_FEATURE_SIMPLE_SCALAR_REDUCTIONS`).

`common/build-examples.sh` will attempt to build all subdirectories of the `examples` folder as standalone projects. If any of those reports an error containing the substring `Skip this test`, it will not propagate the non-zero status but continue without that build. This is currently used by the `reduction` example.

