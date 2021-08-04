FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive 
RUN apt update \
    && apt full-upgrade -y \
    && apt install -y --no-install-recommends git ca-certificates build-essential clang-10 \
        cmake python3 ccache \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-10 20 \
        --slave /usr/bin/clang++ clang++ /usr/bin/clang++-10

COPY --chown=root:root build-dpc++.sh /root/build-dpc++.sh
CMD sh /root/build-dpc++.sh
