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

RUN \
  echo 'deb-src http://deb.debian.org/debian/ bookworm main contrib \
  deb-src http://deb.debian.org/debian/ bookworm-updates main contrib \
  deb-src http://deb.debian.org/debian/ bookworm-backports main contrib \
  deb-src http://security.debian.org/debian-security/ bookworm-security main contrib \
  ' >> /etc/apt/sources.list

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
