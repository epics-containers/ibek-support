#!/bin/bash
##########################################################################
##### boilerplate install script for support modules #####################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)

# get the name of this folder which is the same as name of the support module
NAME=$(basename $(dirname ${0}))
VERSION=${1}

IBEK_SUPPORT=$(realpath $(dirname ${0})/..)
source $IBEK_SUPPORT/_global/functions.sh

git_clone_tag ${NAME} ${VERSION}

# No need for IPAC unless its already installed
write_local_files IPAC --remove

write_local_files ${NAME}

##########################################################################
##### put patch commands here if needed ##################################
##########################################################################

if [[ $TARGET_ARCHITECTURE == "rtems" ]]; then
    # don't build the test directories (they don't compile on RTEMS)
    sed -i '/DIRS += .*test/d' Makefile
fi

##########################################################################
#### end of patch commands ###############################################
##########################################################################


build_support_module ${NAME}

create_links ${NAME}

