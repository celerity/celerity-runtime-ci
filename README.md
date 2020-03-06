# Celerity Docker CI

Docker container for running Celerity CI jobs on GPUC1/2.

## Setup

This container requires support for BuildKit, which was introduced in Docker 18.09.

To build this container, two things have to be provided:

- A valid GitHub action runner token, which has to be placed into a file called
	`token.txt`. This token can be obtained from the GitHub repository settings.
- A ComputeCpp installation, which should be extracted from the tarball into
	a directory called `computecpp` (i.e., this directory should contain the
	`bin` and `lib` folders etc).

To build it, simply run `./build.sh`.

## Running

Simply run the `celerity-ci-runner:latest` image, passing the `--gpus` flag. To enable
NVIDIA GPU passthrough, be sure to install the [NVIDIA Container
Runtime](https://nvidia.github.io/nvidia-container-runtime/).

This container can be run [_rootless_](https://docs.docker.com/engine/security/rootless).
To make GPU passthrough work for rootless, as of Docker 19.03, `cgroups` need
to be disabled. This can be done by providing the
`nvidia-container-runtime-hook-config.toml` file to the Docker runtime hook
using the `nvidia-container-runtime-hook` wrapper provided in this repository.

## Installing as a service

The Celerity CI container can be run automatically upon system restart by
starting it with `--restart always`. If using rootless, the Docker service
needs to additionally be started automatically by enabling systemd lingering.

