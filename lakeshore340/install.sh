#!/bin/bash

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=lakeshore340
FOLDER=$(dirname $(readlink -f $0))

# log output and abort on failure
set -xe

# doxygen is used in documentation build for the developer stage
ibek support apt-install doxygen

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION} --org https://github.com/DiamondLightSource/

ibek support register ${NAME}

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
# None required for a stream device ------------------------------------
#ibek support add-libs
#ibek support add-dbds

# global config settings
${FOLDER}/../_global/install.sh ${NAME}

# compile the support module
ibek support compile ${NAME}
# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}


