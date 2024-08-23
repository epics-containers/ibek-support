#!/bin/bash
##########################################################################
##### install script for pvxs support module #############################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=pvxs
FOLDER=$(dirname $(readlink -f $0))

if [[ $EPICS_TARGET_ARCH == "RTEMS"* ]]; then
    echo "pvxs is not supported on RTEMS"
else

    # log output and abort on failure
    set -xe

    # install required system dependencies
    ibek support apt-install libevent-dev

    # declare packages for installation in the Dockerfile's runtime stage
    ibek support add-runtime-packages libevent-dev

    # get the source and fix up the configure/RELEASE files
    ibek support git-clone ${NAME} ${VERSION} --org http://github.com/mdavidsaver
    ibek support register ${NAME}

    # don't build test folders
    sed -i -E 's/(^[^#].*example)/# \1/' ${SUPPORT}/${NAME}/Makefile
    sed -i -E 's/(^[^#].*test)/# \1/' ${SUPPORT}/${NAME}/Makefile

    # declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
    ibek support add-libs pvxs pvxsIoc
    ibek support add-dbds pvxsIoc.dbd

    # global config settings
    ${FOLDER}/../_global/install.sh ${NAME}

    # compile the support module
    ibek support compile ${NAME}
fi
