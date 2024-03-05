#!/bin/bash

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=StreamDevice
FOLDER=$(dirname $(readlink -f $0))

# log output and abort on failure
set -xe

# prce developer library
ibek support apt-install --only=dev libpcre3-dev

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION} --org https://github.com/paulscherrerinstitute/
ibek support register ${NAME}

# set CALC blank (to overwrite the RELEASE value) to build without calc
ibek support add-release-macro CALC

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs stream
ibek support add-dbds stream-base.dbd stream.dbd

# declare location of the pcre system library
ibek support add-config-macro ${NAME} PCRE_LIB /usr/lib/x86_64-linux-gnu

# compile the support module
ibek support compile ${NAME}
# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}
