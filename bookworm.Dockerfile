FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN \
  apt update && apt upgrade -y && \
  apt install -y \
    build-essential \
    debhelper \
    devscripts equivs \
    software-properties-common

CMD ["/bin/sh","-l"]
