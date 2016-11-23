#
# Base image for compiling and running Ceylon applications
#
FROM ceylon/ceylon-base:jre7-debian

MAINTAINER Tako Schotanus <tako@ceylon-lang.org>

ENV CEYLON_VERSION 1.0.0

LABEL org.ceylon-lang.dockerfile.description="Base image for compiling and running Ceylon applications" \
    org.ceylon-lang.dockerfile.vendor="RedHat" \
    org.ceylon-lang.dockerfile.version="2.0" \
    org.ceylon-lang.ceylon.version="${CEYLON_VERSION}"

USER root

RUN apt-get -y update && \
    apt-get install -y ceylon-${CEYLON_VERSION} && \
    apt-get clean

USER 1000

ADD bootstrap.sh /bootstrap.sh

CMD ["/bootstrap.sh"]

