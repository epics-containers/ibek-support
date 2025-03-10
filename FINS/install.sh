#!/bin/bash

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=FINS
FOLDER=$(dirname $(readlink -f $0))

# log output and abort on failure
set -xe

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION} --org https://github.com/DiamondLightSource

ibek support register ${NAME}

# no dbds/libs for a streamdevice
ibek support add-libs FINS
ibek support add-dbds FINS.dbd

# global config settings
${FOLDER}/../_global/install.sh ${NAME}

# don't build opis with proprietary dls runcss.sh
sed -i '/opi/d'  ${SUPPORT}/${NAME}/FINSApp/Makefile

# compile the support module
ibek support compile ${NAME}
# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}