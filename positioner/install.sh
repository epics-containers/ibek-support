#!/bin/bash

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=positioner
FOLDER=$(dirname $(readlink -f $0))

# log output and abort on failure
set -xe

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION} --org https://github.com/DiamondLightSource/
ibek support register ${NAME}

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
# NONE required for StreamDevice


# comment out the documentation from the Makefile - idempotent because it searches
# for lines not starting with # and inserts a # at the start of the line.
# sed -i -E 's/(^[^#].*documentation)/# \1/' ${SUPPORT}/${NAME}/Makefile

# global config settings
${FOLDER}/../../ibek-support/_global/install.sh ${NAME}

# compile the support module
ibek support compile ${NAME}
# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}