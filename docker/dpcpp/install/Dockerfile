FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive 
RUN apt update \
    && apt full-upgrade -y \
    && apt install -y --no-install-recommends build-essential cmake libopenmpi-dev openmpi-bin

COPY --chown=root:root opt/dpcpp /opt/dpcpp
COPY --chown=root:root VERSION /VERSION
COPY --chown=root:root build-celerity.sh /root/build-celerity.sh

ENV PATH="/opt/dpcpp/bin:${PATH}"

