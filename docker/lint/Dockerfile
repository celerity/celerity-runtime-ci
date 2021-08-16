FROM ubuntu:20.04

COPY --chown=root:root common/setup-user.sh /root/setup-user.sh
RUN bash /root/setup-user.sh

COPY --chown=root:root common/install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh clang-10 clang-format-10 clang-tidy-10

USER user

