#
# Base image for compiling and running Ceylon applications
#
FROM ceylon/ceylon:1.2.1-jre8-redhat

USER 1000

VOLUME ${HOME}

ONBUILD ADD . ${HOME}

