#!/bin/bash

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=calc
FOLDER=$(dirname $(readlink -f $0))

# log output and abort on failure
set -xe

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION}
ibek support register ${NAME}

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs calc
ibek support add-dbds aCalcoutRecord.dbd  calc.dbd  calcSupport.dbd sCalcoutRecord.dbd transformRecord.dbd

# comment out the test directories from the Makefile
sed -i -E 's/tests/# tests/' ${SUPPORT}/${NAME}/Makefile

# global config settings
${FOLDER}/../_global/install.sh

# compile the support module
ibek support compile ${NAME}
# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}


