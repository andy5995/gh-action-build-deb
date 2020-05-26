FROM ubuntu:focal

RUN apt-get update && apt-get upgrade -y && \
 apt-get install build-essential debhelper devscripts -y

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
