FROM debian:bookworm

ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=$DEBIAN_FRONTEND

RUN \
  apt update && apt upgrade -y && \
  apt install -y \
    build-essential \
    debhelper \
    devscripts equivs \
    software-properties-common

RUN sed -i 's/Types: deb/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources

ENTRYPOINT ["/workspace/_gh-action-build-deb/entrypoint.sh"]
