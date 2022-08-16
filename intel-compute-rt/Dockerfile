ARG UBUNTU
FROM ubuntu:${UBUNTU}

COPY --chown=root:root common/install-system.sh download-assets.sh list-download-urls.py /root/
RUN bash /root/install-system.sh ca-certificates curl python3 ocl-icd-libopencl1

# FROM clears all ARG-bindings, so bind $INTEL_COMPUTE_RT and $INTEL_IGC here
ARG INTEL_COMPUTE_RT
ARG INTEL_IGC
RUN mkdir /root/debs \
    && cd /root/debs \
    && bash /root/download-assets.sh intel/intel-graphics-compiler igc-${INTEL_IGC} .deb \
    && bash /root/download-assets.sh intel/compute-runtime ${INTEL_COMPUTE_RT} .deb .ddeb .sum \
    && sha256sum -c *.sum \
    && dpkg -i *.deb *.ddeb \
    && cd .. \
    && rm -rf debs
