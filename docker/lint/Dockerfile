FROM ubuntu:20.04

COPY install-system.sh /root/install-system.sh
RUN bash /root/install-system.sh clang-10 clang-format-10 clang-tidy-10

USER user
CMD sh /root/lint-celerity.sh  # TODO

