#!/bin/bash
##########################################################################
##### install script for Asyn support modules ############################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=asyn
FOLDER=$(dirname $(readlink -f $0))

# log output and abort on failure
set -xe

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION}
ibek support register ${NAME}

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs asyn
ibek support add-dbds drvAsynIPPort.dbd drvAsynSerialPort.dbd asyn.dbd

# No need for IPAC unless its already installed
ibek support add-release-macro IPAC --no-replace

ibek support add-config-macro ${NAME} TIRPC YES

# comment out the test directories from the Makefile
sed -i -E 's/(^[^#].*(test|iocBoot).*$)/# \1/' ${SUPPORT}/${NAME}/Makefile

# global config settings
${FOLDER}/../_global/install.sh

# compile the support module
ibek support compile ${NAME}

# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}


