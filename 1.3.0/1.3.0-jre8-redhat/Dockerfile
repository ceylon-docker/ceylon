#
# Base image for compiling and running Ceylon applications
#
FROM ceylon/ceylon-base:jre8-redhat

MAINTAINER Tako Schotanus <tako@ceylon-lang.org>

ENV CEYLON_VERSION=1.3.0

LABEL org.ceylon-lang.dockerfile.description="Base image for compiling and running Ceylon applications" \
    org.ceylon-lang.dockerfile.vendor="RedHat" \
    org.ceylon-lang.dockerfile.version="2.0" \
    org.ceylon-lang.ceylon.version="${CEYLON_VERSION}"

USER root

RUN yum install -y ceylon-${CEYLON_VERSION} && \
    yum clean all

USER 1000

ADD bootstrap.sh /bootstrap.sh

CMD ["/bootstrap.sh"]

