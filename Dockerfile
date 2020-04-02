# syntax = docker/dockerfile:1.0-experimental
# We use CUDA 10.0 since Clang 8 cannot support newer versions
FROM nvidia/cuda:10.0-devel-ubuntu18.04

RUN apt update && \
	apt install -y curl git clang-8 libclang-8-dev cmake ninja-build python3

RUN useradd --create-home --shell /bin/bash --uid 1337 cirunner

# Build OpenMPI
RUN mkdir /tmp/openmpi
WORKDIR /tmp/openmpi
RUN curl -O -L https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.2.tar.gz && \
	tar -xf *.tar.gz && \
	cd openmpi-4.0.2 && \
	./configure && \
	make -j$(nproc) install

# Build hipSYCL
ARG hipSYCL_VERSION=5f30bc1f
RUN git clone https://github.com/illuhad/hipSYCL \
	--branch=master --single-branch --shallow-since=2020-02-01 \
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

# Add ComputeCpp
RUN apt install -y nvidia-compute-utils-440 nvidia-opencl-dev
COPY --chown=cirunner:cirunner computecpp /computecpp

# Install Celerity dependencies
RUN apt install -y libboost-dev libboost-graph-dev

# Install tools
RUN apt install -y clang-tidy-8 clang-format-8

# Install GitHub Action Runner
RUN mkdir /home/cirunner/actions-runner
WORKDIR /home/cirunner/actions-runner

RUN curl -O -L https://github.com/actions/runner/releases/download/v2.165.2/actions-runner-linux-x64-2.165.2.tar.gz && \
	tar -xf *.tar.gz

RUN bin/installdependencies.sh

RUN chown -R cirunner:cirunner .

USER cirunner

RUN --mount=type=secret,id=token,required,uid=1337 \
	cd /home/cirunner/actions-runner && \
	./config.sh --unattended --name dps-gpuc --replace \
	--url https://github.com/celerity/celerity-runtime \
	--token $( head -n 1 /run/secrets/token )

COPY --chown=cirunner:cirunner scripts /scripts
COPY --chown=cirunner:cirunner data /data

CMD ./run.sh

