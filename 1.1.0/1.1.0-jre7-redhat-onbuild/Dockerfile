#
# Base image for compiling and running Ceylon applications
#
FROM ceylon/ceylon:1.1.0-jre7-redhat

USER 1000

VOLUME ${HOME}

ONBUILD ADD . ${HOME}

