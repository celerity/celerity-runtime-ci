# Celerity Docker CI

Docker container for running Celerity CI jobs on gpuc1/2 and nuc21.

## Setup

This container requires support for BuildKit, which was introduced in Docker 18.09.

To build this container, some things have to be provided:

- A valid GitHub action runner token, which has to be placed into a file called
	`token.txt`. This token can be obtained from the GitHub repository settings.
- When ComputeCpp is enabled, a ComputeCpp installation needs to be provided,
	which should be extracted from the tarball into a directory called `computecpp`
	(i.e., this directory should contain the `bin` and `lib` folders etc).

To build the container image, use the `./build.sh` script. The script takes several
parameters, for example the hardware platform to target (either Intel or NVIDIA),
and which SYCL implementations to enable.

For convenience two wrapper scripts are provided:
	- `./build-gpuc1.sh` builds the image for the NVIDIA platform, running on gpuc1.
	- `./build-nuc21.sh` builds the image for the Intel platform, running on nuc21.

## Running on Intel

To access Intel integrated GPUs, the device file needs to be mounted into the
container: `docker run --device=/dev/dri/render*`.

## Running on NVIDIA

Simply run the `celerity-ci-runner:latest` image, passing the `--gpus` flag. To enable
NVIDIA GPU passthrough, be sure to install the [NVIDIA Container
Runtime](https://nvidia.github.io/nvidia-container-runtime/).

For NVIDIA, this container can be run [_rootless_](https://docs.docker.com/engine/security/rootless).
To make GPU passthrough work for rootless, as of Docker 19.03, `cgroups` need
to be disabled. This can be done by providing the
`nvidia-container-runtime-hook-config.toml` file to the Docker runtime hook
using the `nvidia-container-runtime-hook` wrapper provided in this repository.

## Installing as a service

The Celerity CI container can be run automatically upon system restart by
starting it with `--restart always`. If using rootless, the Docker service
needs to additionally be started automatically by enabling systemd lingering.

To disable auto-restart again, use `docker update --restart=no <container>`.

