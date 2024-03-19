#!/bin/bash

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=quadEM
FOLDER=$(dirname $(readlink -f $0))

# log output and abort on failure
set -xe

# doxygen is used in documentation build for the developer stage
ibek support apt-install doxygen

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION} --org https://github.com/epics-modules/

ibek support register ${NAME}

# remove IPUNIDIG from configure/RELEASE
ibek support add-release-macro IPUNIDIG

# do not make VxWorks dbds
sed -i /epics/support/quadEM/quadEMApp/src/Makefile -e /quadEMTestAppVx.dbd/d

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
# None required for a stream device ------------------------------------
ibek support add-libs quadEM
ibek support add-dbds drvTetrAMM.dbd

# global config settings
${FOLDER}/../_global/install.sh ${NAME}

# compile the support module
ibek support compile ${NAME}
# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}