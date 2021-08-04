FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update \
    && apt full-upgrade -y \
    && apt install -y --no-install-recommends clang-10 clang-format-10 clang-tidy-10 \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-10 20 \
        --slave /usr/bin/clang++ clang++ /usr/bin/clang++-10 \
        --slave /usr/bin/clang-format clang-format /usr/bin/clang-format-10 \
        --slave /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-10

CMD sh /root/lint-celerity.sh

