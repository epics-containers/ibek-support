#!/bin/bash
##########################################################################
##### install script for iocStats support module #########################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=iocStats
FOLDER=$(dirname $(readlink -f $0))

# log output and abort on failure
set -xe

if [[ $TARGET_ARCHITECTURE == "RTEMS"* ]]; then
# apply Paul Hamadyk's fix's to iocStats for RTEMS6
(
    cd ${SUPPORT}
    if [ ! -d ${SUPPORT}/${NAME} ]; then
        git clone http://github.com/epics-modules/iocStats.git
    fi
    cd ${SUPPORT}/${NAME}
    git reset --hard '4226b12'
    git apply ${FOLDER}/iocStats.patch
)
else
    ibek support git-clone ${NAME} ${VERSION}
fi

# get the source and fix up the configure/RELEASE files
ibek support register ${NAME}

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs devIocStats
ibek support add-dbds devIocStats.dbd

# global config settings
${FOLDER}/../_global/install.sh

# comment out the test directories from the Makefile
sed -i -E 's/(^[^#].*+= test.*$)/# \1/' ${SUPPORT}/${NAME}/Makefile

# compile the support module
ibek support compile ${NAME}

# fixup incorrect timezone variable name in template. TODO: why is this needed?
sed -i 's|@EPICS_TIMEZONE|@EPICS_TZ|' ${SUPPORT}/${NAME}/db/iocAdminSoft.db

# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}
