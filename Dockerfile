ARG CODENAME=bookworm
FROM debian:$CODENAME-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN \
  apt update && apt upgrade -y && \
  apt install -y \
    build-essential \
    debhelper \
    devscripts \
    equivs && \
    if [ "$CODENAME" = "bookworm" ]; then \
      apt install -y software-properties-common; \
    fi

RUN sed -i 's/Types: deb/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources

#COPY entrypoint.sh /entrypoint.sh
# The file is mounted by the action at runtime
ENTRYPOINT ["/entrypoint.sh"]
