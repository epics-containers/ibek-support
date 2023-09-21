#!/bin/bash
##########################################################################
##### boilerplate install script for support modules #####################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}

set -xe

THIS_DIR=$(dirname ${0})

# get the name of this folder, i.e. the name of the support module
NAME=$(basename $(dirname ${0}))

ibek support git-clone ${NAME} ${VERSION}
ibek support register ${NAME}
ibek support add-libs autosave
ibek support add-dbds asSupport.dbd

##########################################################################
##### put patch commands here if needed ##################################
##########################################################################

if [[ $TARGET_ARCHITECTURE == "rtems" ]]; then
    echo "Patching RTEMS autosave"
    patch -p1 < ${THIS_DIR}/rtems-autosave.patch

    echo >> ${SUPPORT}/${NAME}/configure/CONFIG_SITE.Common.linux-x86_64
    echo "VALID_BUILDS=Host" >> configure/CONFIG_SITE.Common.linux-x86_64
fi

##########################################################################
#### end of patch commands ###############################################
##########################################################################

ibek support compile ${NAME}
ibek support generate-links ${NAME}


