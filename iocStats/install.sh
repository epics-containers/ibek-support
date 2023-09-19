#!/bin/bash
##########################################################################
##### boilerplate install script for support modules #####################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}

# get the name of this folder, i.e. the name of the support module
NAME=$(basename $(dirname ${0}))

ibek support git-clone ${NAME} ${VERSION}
ibek support register ${NAME}
ibek support add-libs ${NAME} devIocStats
ibek support add-dbds ${NAME} devIocStats.dbd

##########################################################################
##### put patch commands here if needed ##################################
##########################################################################

ibek support compile ${NAME}
ibek support generate-links ${NAME}

