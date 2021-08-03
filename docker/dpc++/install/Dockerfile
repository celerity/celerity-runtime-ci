FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive 
RUN apt update \
    && apt full-upgrade -y \
    && apt install -y --no-install-recommends build-essential cmake

COPY --chown=root:root opt/dpc++ /opt/dpc++
COPY --chown=root:root VERSION /VERSION
ENV PATH="/opt/dpc++/bin:${PATH}"

