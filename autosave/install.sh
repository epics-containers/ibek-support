#!/bin/bash
##########################################################################
##### install script for autosave module #################################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=autosave

# log output and abort on failure
set -xe

# get the name of this folder, i.e. the name of the support module
NAME=$(basename $(dirname ${0}))

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION}
ibek support register ${NAME}


# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs autosave
ibek support add-dbds asSupport.dbd

# Patches for RTEMS
THIS_DIR=$(dirname ${0})

if [[ $TARGET_ARCHITECTURE == "rtems" ]]; then
    echo "Patching RTEMS autosave"
    patch -p1 < ${THIS_DIR}/rtems-autosave.patch

    echo >> ${SUPPORT}/${NAME}/configure/CONFIG_SITE.Common.linux-x86_64
    echo "VALID_BUILDS=Host" >> configure/CONFIG_SITE.Common.linux-x86_64
fi

# compile the support module
ibek support compile ${NAME}
# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links


