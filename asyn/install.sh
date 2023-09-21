#!/bin/bash
##########################################################################
##### boilerplate install script for support modules #####################
##########################################################################


# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}

set -xe

# get the name of this folder, i.e. the name of the support module
NAME=$(basename $(dirname ${0}))

ibek support git-clone ${NAME} ${VERSION}
ibek support register ${NAME}
ibek support add-libs asyn
ibek support add-dbds asyn.dbd

##########################################################################
##### put patch commands here if needed ##################################
##########################################################################

# No need for IPAC unless its already installed
ibek support add-release-macro IPAC --no-replace

if [[ $TARGET_ARCHITECTURE == "rtems" ]]; then
    # don't build the test directories (they don't compile on RTEMS)
    sed -i '/DIRS += ${SUPPORT}/${NAME}.*test/d' Makefile
else
    ibek support add-config-macro ${NAME} TIRPC YES
fi

##########################################################################
#### end of patch commands ###############################################
##########################################################################

ibek support compile ${NAME}
ibek support generate-links ${NAME}


