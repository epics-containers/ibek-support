#!/bin/bash
##########################################################################
###### install script for ADSimDetector Module ###########################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=lakeshore340
FOLDER=$(dirname $(readlink -f $0))

# log output and abort on failure
set -xe

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION} --org https://github.com/DiamondLightSource/
# overwrite hard coded DLS release file
echo 'include $(TOP)/configure/RELEASE.local' > /epics/support/${NAME}/configure/RELEASE

ibek support register ${NAME}

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
# None required for a stream device ------------------------------------
#ibek support add-libs
#ibek support add-dbds

# compile the support module
ibek support compile ${NAME}
# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}


