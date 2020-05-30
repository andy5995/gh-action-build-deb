FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && \
 apt-get install build-essential debhelper devscripts equivs \
 software-properties-common -y

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
