# SPDX-License-Identifier: GPL-2.0
ARG BASE_IMAGE
FROM $BASE_IMAGE as builder

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt -y update && apt -y upgrade && \
  DEBIAN_FRONTEND=noninteractive apt -y install \
  apt-utils autoconf git g++ make \
  libpthread-stubs0-dev

RUN git clone https://github.com/slowkoni/rfmix.git

RUN cd rfmix && \
  autoreconf --force --install && \
  ./configure && \
  make

FROM $BASE_IMAGE

ARG RUN_CMD

COPY --from=builder /rfmix/rfmix /usr/local/bin/rfmix
RUN chmod +x /usr/local/bin/rfmix

ARG ENTRY="/entrypoint.sh"
RUN echo "#!/bin/bash\n$RUN_CMD \$@" > ${ENTRY} && chmod ugo+rx ${ENTRY}
ENTRYPOINT [ "/entrypoint.sh" ]
