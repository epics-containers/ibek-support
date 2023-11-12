#!/bin/bash
##########################################################################
###### install script for the epics motor module #########################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=motor

# log output and abort on failure
set -xe

# get the source and fix up the configure/RELEASE files
# TODO sadly DLS has a fork of the motor module - ACTION wean us off this
ibek support git-clone ${NAME} ${VERSION} --org http://github.com/dls-controls/
ibek support register ${NAME}

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs softMotor motor
ibek support add-dbds motorRecord.dbd motorSupport.dbd devSoftMotor.dbd

# compile the support module
ibek support compile ${NAME}
# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${NAME}
