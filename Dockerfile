# syntax = docker/dockerfile:1.0-experimental

# The base image to use, either "intel" or "nvidia"
ARG VENDOR_BASE_IMAGE

# SYCL implementations can be enabled conditionally, so we need to set the
# base image for each step externally. BuildKit ensures that steps that
# aren't required for the final image are omitted.
ARG HIPSYCL_BASE_IMAGE
ARG COMPUTECPP_BASE_IMAGE
ARG ACTIONS_RUNNER_BASE_IMAGE

# Name and labels of the GitHub actions runner (as displayed in GitHub's UI).
# Can be used for selecting specific runners from within workflow file.
ARG RUNNER_NAME
ARG RUNNER_LABELS

# We expect a list of all enabled SYCL implementations, as a JSON array.
ARG SYCL_IMPLS_JSON

# On Intel we require the user to belong to "render" group, which needs to have
# the same group ID as the host (we mount the GPU device into the container).
ARG RENDER_GID=999

## ----------------------------------------------------------------------------
## ------------------------------- intel-base --------------------------------
## ----------------------------------------------------------------------------

FROM ubuntu:20.04 AS intel-base

RUN apt update && \
	apt install -y ocl-icd-opencl-dev opencl-headers \
	intel-opencl-icd

## ----------------------------------------------------------------------------
## ------------------------------- nvidia-base --------------------------------
## ----------------------------------------------------------------------------

FROM nvidia/cuda:11.3.0-devel-ubuntu20.04 AS nvidia-base

# HACK: CUDA 11 no longer includes the "version.txt" file used by Clang to
# determine compatibility, which leads it to assume CUDA version 7.0.
#
# While this has been fixed in some newer LLVM release (see
# https://reviews.llvm.org/D89752) for Clang 10 we have to
# manually create this file.
RUN echo "CUDA Version 11.3.0" > /usr/local/cuda/version.txt

## ----------------------------------------------------------------------------
## ---------------------------------- tools -----------------------------------
## ----------------------------------------------------------------------------

FROM ${VENDOR_BASE_IMAGE}-base AS tools-base
# Set timezone to avoid problems when installing tzdata
RUN ln -snf /usr/share/zoneinfo/Europe/Vienna /etc/localtime && \
	echo "Europe/Vienna" > /etc/timezone

RUN apt update && \
	apt install -y git \
	curl \
	cmake \
	ninja-build \
	libopenmpi-dev openmpi-bin \
	clang-10 \
	clang-tidy-10 clang-format-10

# Rename clang executables to their canonical names without version,
# so CMake can find it, and we can simply use e.g. `clang-format` in scripts.
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-10 20 \
	--slave /usr/bin/clang++ clang++ /usr/bin/clang++-10 \
	--slave /usr/bin/clang-format clang-format /usr/bin/clang-format-10 \
	--slave /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-10

# Create "cirunner" user and add it to the "render" group so it can access
# the mounted GPU device (only required for Intel).
ARG RENDER_GID
RUN useradd --create-home --shell /bin/bash --uid 1337 cirunner && \
	groupadd render --gid $RENDER_GID && \
	usermod -aG render cirunner

## ----------------------------------------------------------------------------
## --------------------------------- hipSYCL ----------------------------------
## ----------------------------------------------------------------------------

FROM ${HIPSYCL_BASE_IMAGE}-base AS hipsycl-base

# Install hipSYCL dependencies
RUN apt install -y \
	libboost-dev libboost-context-dev libboost-fiber-dev \
	libclang-10-dev

# Build hipSYCL
ARG hipSYCL_VERSION=a2c63617
RUN git clone https://github.com/illuhad/hipSYCL \
	--branch=develop --single-branch --shallow-since=2021-05-01 \
	--recurse-submodules /tmp/hipSYCL && \
	cd /tmp/hipSYCL && \
	git checkout $hipSYCL_VERSION && \
	mkdir /tmp/hipSYCL-build
WORKDIR /tmp/hipSYCL-build
ENV LIBRARY_PATH=/usr/local/cuda/lib64:$LIBRARY_PATH
ENV CUDA_PATH=/usr/local/cuda
ENV PATH=/usr/local/cuda/bin:$PATH
RUN cmake -G Ninja /tmp/hipSYCL \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=/sycl/hipSYCL \
	-DWITH_CPU_BACKEND=OFF \
	-DWITH_CUDA_BACKEND=ON && \
	ninja install

## ----------------------------------------------------------------------------
## ------------------------------- ComputeCpp ---------------------------------
## ----------------------------------------------------------------------------

FROM ${COMPUTECPP_BASE_IMAGE}-base AS computecpp-base

COPY --chown=cirunner:cirunner computecpp /sycl/computecpp

## ----------------------------------------------------------------------------
## ----------------------------- Actions Runner -------------------------------
## ----------------------------------------------------------------------------

FROM ${ACTIONS_RUNNER_BASE_IMAGE}-base AS actions-runner

COPY --chown=cirunner:cirunner computecpp /sycl/computecpp

# Install GitHub Action Runner
RUN mkdir /home/cirunner/actions-runner
WORKDIR /home/cirunner/actions-runner

# Action runner update script uses `ping` which does not
# come with this Ubuntu base image...
RUN apt install -y iputils-ping

RUN curl -O -L https://github.com/actions/runner/releases/download/v2.278.0/actions-runner-linux-x64-2.278.0.tar.gz && \
	tar -xf *.tar.gz

RUN bin/installdependencies.sh

RUN chown -R cirunner:cirunner .

USER cirunner

# NOTE: As of docker/dockerfile:1.0-experimental it seems like changing a build secret does not invalidate
# the cache of this command. To force this step to run again, temporarily add something like "RUN echo foo" above.
ARG RUNNER_NAME
ARG RUNNER_LABELS
RUN --mount=type=secret,id=token,required,uid=1337 \
	cd /home/cirunner/actions-runner && \
	./config.sh --unattended --name $RUNNER_NAME --replace \
	--url https://github.com/celerity/celerity-runtime \
	--labels $RUNNER_LABELS \
	--token $( head -n 1 /run/secrets/token )

COPY --chown=cirunner:cirunner scripts /scripts
COPY --chown=cirunner:cirunner data /data

ARG SYCL_IMPLS_JSON
ENV SYCL_IMPLS_JSON_ENV=${SYCL_IMPLS_JSON}
CMD ["/scripts/docker-entrypoint.sh", "run.sh"]

