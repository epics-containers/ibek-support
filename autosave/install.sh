#!/bin/bash
##########################################################################
##### install script for autosave module #################################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=autosave
FOLDER=$(dirname $(readlink -f $0))

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

# global config settings
${FOLDER}/../_global/install.sh ${NAME}

# compile the support module
ibek support compile ${NAME}
# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}


