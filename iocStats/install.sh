#!/bin/bash
##########################################################################
##### install script for iocStats support module #########################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=iocStats

# log output and abort on failure
set -xe

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION}
ibek support register ${NAME}

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs devIocStats
ibek support add-dbds devIocStats.dbd

# compile the support module
ibek support compile ${NAME}

# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links

