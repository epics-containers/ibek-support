#!/bin/bash
##########################################################################
##### install script for Asyn support modules ############################
##########################################################################


# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=asyn

# log output and abort on failure
set -xe

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION}
ibek support register ${NAME}

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs asyn
ibek support add-dbds asyn.dbd

# No need for IPAC unless its already installed
ibek support add-release-macro IPAC --no-replace

# Patches to the CONFIG_SITE
if [[ $TARGET_ARCHITECTURE == "rtems" ]]; then
    # don't build the test directories (they don't compile on RTEMS)
    sed -i '/DIRS += ${SUPPORT}/${NAME}.*test/d' Makefile
else
    ibek support add-config-macro ${NAME} TIRPC YES
fi

# compile the support module
ibek support compile ${NAME}

# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links


