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
ibek support add-libs ${NAME} asyn
ibek support add-dbds ${NAME} asyn.dbd

##########################################################################
##### put patch commands here if needed ##################################
##########################################################################

# No need for IPAC unless its already installed
ibek support add-macro IPAC --no-replace

if [[ $TARGET_ARCHITECTURE != "rtems" ]]; then
    echo "TIRPC=YES" >> configure/CONFIG_SITE.linux-x86_64.Common
else
    # don't build the test directories (they don't compile on RTEMS)
    sed -i '/DIRS += .*test/d' Makefile
fi

##########################################################################
#### end of patch commands ###############################################
##########################################################################

ibek support compile ${NAME}
ibek support generate-links ${NAME}


