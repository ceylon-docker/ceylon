#
# Base image for compiling and running Ceylon applications
#
FROM ceylon/ceylon:1.3.1-jre8-debian

USER 1000

VOLUME ${HOME}

ONBUILD ADD . ${HOME}

