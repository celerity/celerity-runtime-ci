# syntax = docker/dockerfile:1.0-experimental
# We use CUDA 10.0 since Clang 8 cannot support newer versions
FROM nvidia/cuda:10.0-devel-ubuntu18.04

RUN apt update && \
	apt install -y software-properties-common curl clang-8 libclang-8-dev ninja-build python3
# GitHub runner wants git >= 2.18, but Ubuntu 18.04 ships 2.17
RUN apt-add-repository -y ppa:git-core/ppa && \
	apt install -y git

# We require CMake >= 3.13
RUN curl https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | \
	gpg --dearmor - | \
	tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
	apt-add-repository -y 'deb https://apt.kitware.com/ubuntu/ bionic main' && \
	apt install -y cmake

RUN useradd --create-home --shell /bin/bash --uid 1337 cirunner

# Build OpenMPI
RUN mkdir /tmp/openmpi
WORKDIR /tmp/openmpi
RUN curl -O -L https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.2.tar.gz && \
	tar -xf *.tar.gz && \
	cd openmpi-4.0.2 && \
	./configure && \
	make -j$(nproc) install

# Install hipSYCL dependencies
RUN apt install -y libboost-dev libboost-context-dev libboost-fiber-dev

# Build hipSYCL
ARG hipSYCL_VERSION=v0.9.0
RUN git clone https://github.com/illuhad/hipSYCL \
	--branch=develop --single-branch --shallow-since=2020-12-09 \
	--recurse-submodules /tmp/hipSYCL && \
	cd /tmp/hipSYCL && \
	git checkout $hipSYCL_VERSION && \
	mkdir /tmp/hipSYCL-build
WORKDIR /tmp/hipSYCL-build
ENV LIBRARY_PATH=/usr/local/cuda/lib64:$LIBRARY_PATH
ENV CUDA_PATH=/usr/local/cuda
ENV PATH=/usr/local/cuda/bin:$PATH
RUN cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/sycl/hipSYCL -DWITH_CPU_BACKEND=OFF -WIDTH_GPU_BACKEND=ON /tmp/hipSYCL && \
	ninja install

# Install OpenCL (taken from nvidia/opencl Docker images)
RUN apt install -y --no-install-recommends ocl-icd-libopencl1 ocl-icd-opencl-dev
RUN mkdir -p /etc/OpenCL/vendors && \
	echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

# Add ComputeCpp
COPY --chown=cirunner:cirunner computecpp /computecpp

# Install Celerity dependencies
RUN apt install -y libboost-dev libboost-graph-dev libboost-atomic-dev libboost-container-dev

# Install tools
RUN apt install -y clang-tidy-8 clang-format-8

# Install GitHub Action Runner
RUN mkdir /home/cirunner/actions-runner
WORKDIR /home/cirunner/actions-runner

# Action runner update script uses `ping` which does not
# come with this Ubuntu base image...
RUN apt install -y iputils-ping

RUN curl -O -L https://github.com/actions/runner/releases/download/v2.273.5/actions-runner-linux-x64-2.273.5.tar.gz && \
	tar -xf *.tar.gz

RUN bin/installdependencies.sh

RUN chown -R cirunner:cirunner .

USER cirunner

# NOTE: As of docker/dockerfile:1.0-experimental it seems like changing a build secret does not invalidate
# the cache of this command. To force this step to run again, temporarily add something like "RUN echo foo" above.
RUN --mount=type=secret,id=token,required,uid=1337 \
	cd /home/cirunner/actions-runner && \
	./config.sh --unattended --name dps-gpuc --replace \
	--url https://github.com/celerity/celerity-runtime \
	--token $( head -n 1 /run/secrets/token )

COPY --chown=cirunner:cirunner scripts /scripts
COPY --chown=cirunner:cirunner data /data

CMD ["/scripts/docker-entrypoint.sh", "./run.sh"]

