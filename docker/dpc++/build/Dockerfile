FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive 
RUN apt update \
    && apt full-upgrade -y \
    && apt install -y --no-install-recommends git ca-certificates build-essential clang-10 cmake python3 ccache

COPY --chown=root:root build-dpc++.sh /root/build-dpc++.sh
CMD sh /root/build-dpc++.sh
