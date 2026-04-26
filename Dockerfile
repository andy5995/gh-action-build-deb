ARG CODENAME=trixie
FROM debian:$CODENAME-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN \
  apt update && \
  apt install -y --no-install-recommends \
    build-essential \
    curl \
    debhelper \
    devscripts \
    equivs \
    lintian \
    zstd

RUN sed -i 's/Types: deb/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources

RUN useradd -m builder && passwd -d builder

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
