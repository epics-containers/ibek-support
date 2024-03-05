#!/bin/bash

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=sscan
FOLDER=$(dirname $(readlink -f $0))

# log output and abort on failure
set -xe

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION}
ibek support register ${NAME}

# remove sequencer from dependencies unless it has been built in this container
ibek support add-release-macro SNCSEQ --no-replace

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs sscan
ibek support add-dbds sscan.dbd

# compile the support module
ibek support compile ${NAME}
# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}


