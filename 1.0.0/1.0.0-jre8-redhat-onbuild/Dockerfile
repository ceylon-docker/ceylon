#
# Base image for compiling and running Ceylon applications
#
FROM ceylon/ceylon:1.0.0-jre8-redhat

USER 1000

VOLUME ${HOME}

ONBUILD ADD . ${HOME}

