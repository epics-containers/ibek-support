#!/bin/bash
##########################################################################
##### boilerplate install script for support modules #####################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
#  $CONFIG text to add to configure/CONFIG_SITE.Common.linux-x86_64
VERSION=${1}

set -xe

# get the name of this folder, i.e. the name of the support module
NAME=$(basename $(dirname ${0}))

ibek support git-clone ${NAME} ${VERSION} --org http://github.com/areaDetector/
ibek support register ${NAME}
ibek support add-libs ${NAME} TODO
ibek support add-dbds ${NAME} TODO.dbd

##########################################################################
##### put patch commands here if needed ##################################
##########################################################################

ibek support add-to-config-site ${NAME} "${CONFIG}"

##########################################################################
#### end of patch commands ###############################################
##########################################################################

ibek support compile ${NAME}
ibek support generate-links ${NAME}


